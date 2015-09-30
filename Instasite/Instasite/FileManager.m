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
  return [self filesInDirectory:nil templatePath:directory documentsDirectory:documentsDirectory];
}

- (NSArray *)filesInDirectory:(NSString *)directory templatePath:(NSString *)templatePath documentsDirectory:(NSString *)documentsDirectory {

  NSFileManager *manager = [NSFileManager defaultManager];
  NSMutableArray *cssFiles = [[NSMutableArray alloc] init];
  NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
  
  NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:templatePath];
  NSString *templateDirectoryPath = templatePath;
  if (directory) {
    directoryPath = [directoryPath stringByAppendingPathComponent:directory];
    templateDirectoryPath = [templateDirectoryPath stringByAppendingPathComponent:directory];
  }
  
  NSError *error;
  NSArray *files = [manager contentsOfDirectoryAtPath:directoryPath error:&error];
  
  for (NSString *file in files) {
    BOOL isDirectory;
    NSString *filepath = [directoryPath stringByAppendingPathComponent:file];
    [manager fileExistsAtPath:filepath isDirectory:&isDirectory];
    if (isDirectory) {
      //NSLog(@"Directory at: %@", file);
      
      NSArray *fileObjects = [self filesInDirectory:file templatePath:templateDirectoryPath documentsDirectory:documentsDirectory];
      [cssFiles addObjectsFromArray:fileObjects[0]];
      [imageFiles addObjectsFromArray:fileObjects[1]];
      
    } else {
      //NSLog(@"File at: %@", file);
      if ([file hasPrefix:kTemplateImagePrefix]) {
        ImageFile *imagefile = [[ImageFile alloc] initWithPath:templateDirectoryPath andFileName:file andDocumentsDirectory:documentsDirectory];
        [imageFiles addObject:imagefile];
      } else if ([file hasPrefix:kTemplateIndexFilename]) {
        // ignore index.html
      } else if ([file hasPrefix:kTemplateMarkerFilename]) {
        // ignore marker file
      } else if ([file hasPrefix:kTemplateJsonFilename]) {
        // ignore json file
      } else {
        CSSFile *cssfile = [[CSSFile alloc] initWithPath:templateDirectoryPath andFileName:file andDocumentsDirectory:documentsDirectory];
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
