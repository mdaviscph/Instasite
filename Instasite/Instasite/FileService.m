//
//  FileService.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileService.h"
#import "FileInfo.h"
#import "Constants.h"

@implementation FileService

- (NSArray *)enumerateFilesInDirectory:(NSString *)directory type:(FileType) type rootDirectory:(NSString *)rootDirectory {
  
  NSLog(@"Enumerate directory at: %@/%@", rootDirectory, directory);
  return [self filesInDirectory:nil type:type relativePath:nil startingDirectory:directory rootDirectory:rootDirectory];
}

- (NSArray *)filesInDirectory:(NSString *)directory type:(FileType)type relativePath:(NSString *)relativePath startingDirectory:(NSString *)startingDirectory rootDirectory:(NSString *)rootDirectory {

  NSFileManager *fileManager = [NSFileManager defaultManager];
  FileInfoMutableArray *fileList = [[NSMutableArray alloc] init];
  
  NSString *directoryPath = [rootDirectory stringByAppendingPathComponent:startingDirectory];
  directoryPath = relativePath ? [directoryPath stringByAppendingPathComponent:relativePath] : directoryPath;
  directoryPath = directory ? [directoryPath stringByAppendingPathComponent:directory] : directoryPath;
  
  NSString *newRelativePath;
  if (directory) {
    newRelativePath = relativePath ? [relativePath stringByAppendingPathComponent:directory] : directory;
  }
  
  NSError *error;
  NSArray *files = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
  // TODO - handle error
  
  for (NSString *file in files) {
    
    BOOL isDirectory;
    NSString *filepath = [directoryPath stringByAppendingPathComponent:file];
    [fileManager fileExistsAtPath:filepath isDirectory:&isDirectory];
    if (isDirectory) {
      //NSLog(@"Directory at: %@", file);
      
      [fileList addObjectsFromArray:[self filesInDirectory:file type:type relativePath:newRelativePath startingDirectory:startingDirectory rootDirectory:rootDirectory]];
      
    } else {
      //NSLog(@"File at: %@", file);
      
      NSString* fileName = [file stringByDeletingPathExtension];
      NSString* fileExtension = [file pathExtension];
      FileType fileType;
      
      if ([fileExtension isEqualToString:kFileJsonExtension]) {
        fileType = FileTypeJson;
      } else if ([fileExtension isEqualToString:kFileTemplateExtension]) {
        fileType = FileTypeTemplate;
      } else if ([fileExtension isEqualToString:kFileImageExtension]) {
        fileType = FileTypeJpeg;
      } else if ([fileExtension isEqualToString:kFileHtmlExtension]) {
        fileType = FileTypeHtml;
      } else {
        fileType = FileTypeOther;
      }
      if (fileType & type) {
        [fileList addObject:[[FileInfo alloc] initWithFileName:fileName extension:fileExtension type:fileType relativePath:newRelativePath remoteDirectory:startingDirectory localDirectory:rootDirectory]];
      }
    }
  }
  return fileList;
}

- (BOOL)copyDirectory:(NSString *)fromDirectory overwrite:(BOOL)overwrite toDirectory:(NSString *)toDirectory {

  NSFileManager *fileManager = [NSFileManager defaultManager];
  fileManager.delegate = self;
  
  NSString *newDirectory = [toDirectory stringByAppendingPathComponent:fromDirectory];
  NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fromDirectory];

  BOOL directoryExists = [fileManager fileExistsAtPath:newDirectory];
  
  if (directoryExists && !overwrite) {
    return YES;
  }

  NSLog(@"Copying directory from [%@] to [%@]", bundlePath, newDirectory);
  
  NSError *error;
  [fileManager copyItemAtPath:bundlePath toPath:newDirectory error:&error];
  if (error) {
    NSLog(@"Error! Cannot copy directory: [%@] error: %@", newDirectory, error.localizedDescription);
    return NO;
  }
  return YES;
}

#pragma mark - NSFileManagerDelegate

// used if we need to overwrite a directory and files
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
  if (error.code == NSFileWriteFileExistsError) {
    return YES;
  }
  return NO;
}

@end
