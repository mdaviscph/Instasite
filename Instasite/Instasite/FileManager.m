//
//  FileManager.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileManager.h"
#import "CSSFile.h"
#import "ImageFile.h"
#import "Constants.h"

@implementation FileManager

- (NSArray *)enumerateFilesInDirectory:(NSString *)directory documentsDirectory:(NSString *)documentsDirectory{
  
  NSLog(@"Enumerate directory at: %@/%@", documentsDirectory, directory);
  return [self filesInDirectory:nil relativePath:nil startingDirectory:directory documentsDirectory:documentsDirectory];
}

- (NSArray *)filesInDirectory:(NSString *)directory relativePath:(NSString *)relativePath startingDirectory:(NSString *)startingDirectory documentsDirectory:(NSString *)documentsDirectory {

  NSFileManager *manager = [NSFileManager defaultManager];
  NSMutableArray *cssFiles = [[NSMutableArray alloc] init];
  NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
  
  NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:startingDirectory];
  directoryPath = relativePath ? [directoryPath stringByAppendingPathComponent:relativePath] : directoryPath;
  directoryPath = directory ? [directoryPath stringByAppendingPathComponent:directory] : directoryPath;
  
  NSString *newRelativePath;
  if (directory) {
    newRelativePath = relativePath ? [relativePath stringByAppendingPathComponent:directory] : directory;
  }
  
  NSError *error;
  NSArray *files = [manager contentsOfDirectoryAtPath:directoryPath error:&error];
  
  for (NSString *file in files) {
    BOOL isDirectory;
    NSString *filepath = [directoryPath stringByAppendingPathComponent:file];
    [manager fileExistsAtPath:filepath isDirectory:&isDirectory];
    if (isDirectory) {
      //NSLog(@"Directory at: %@", file);
      
      NSArray *fileObjects = [self filesInDirectory:file relativePath:newRelativePath startingDirectory:startingDirectory documentsDirectory:documentsDirectory];
      [cssFiles addObjectsFromArray:fileObjects.firstObject];
      [imageFiles addObjectsFromArray:fileObjects.lastObject];
      
    } else {
      //NSLog(@"File at: %@", file);
      if ([file hasPrefix:kTemplateImagePrefix]) {
        ImageFile *imagefile = [[ImageFile alloc] initWithFileName:file filePath:newRelativePath templateDirectory:startingDirectory documentsDirectory:documentsDirectory];
        [imageFiles addObject:imagefile];
        [cssFiles addObject:imagefile];
      } else if ([file hasPrefix:kTemplateIndexFilename]) {
        // ignore index.html
      } else if ([file hasPrefix:kTemplateMarkerFilename]) {
        // ignore marker file
      } else if ([file hasPrefix:kTemplateJsonFilename]) {
        // ignore json file
      } else {
        CSSFile *cssfile = [[CSSFile alloc] initWithFileName:file filePath:newRelativePath templateDirectory:startingDirectory documentsDirectory:documentsDirectory];
        [cssFiles addObject:cssfile];
      }
    }
  }
  return @[cssFiles, imageFiles];
}

- (BOOL)copyDirectory:(NSString *)directory overwrite:(BOOL)overwrite documentsDirectory:(NSString *)documentsDirectory {

  NSFileManager *fileManager = [NSFileManager defaultManager];
  fileManager.delegate = self;
  
  NSString *newDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
  NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:directory];

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
  if ([error code] == NSFileWriteFileExistsError) {
    return YES;
  }
  return NO;
}

@end
