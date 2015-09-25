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

- (NSArray *)enumerateFilesInDirectory:(NSString *)directory {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSLog(@"Directory at: %@/%@", documentsDirectory, directory);
  return [self filesInDirectory:nil templatePath:directory documentsDirectory:documentsDirectory];
}

- (NSArray *)filesInDirectory:(NSString *)directory templatePath:(NSString *)templatePath documentsDirectory:(NSString *)docDirectory {

  NSFileManager *manager = [NSFileManager defaultManager];
  NSMutableArray *cssFiles = [[NSMutableArray alloc] init];
  NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
  
  NSString *directoryPath = [docDirectory stringByAppendingPathComponent:templatePath];
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
      NSLog(@"Directory at: %@", file);
      
      NSArray *fileObjects = [self filesInDirectory:file templatePath:templateDirectoryPath documentsDirectory:docDirectory];
      [cssFiles addObjectsFromArray:fileObjects[0]];
      [imageFiles addObjectsFromArray:fileObjects[1]];
      
    } else {
      NSLog(@"File at: %@", file);
      if ([file hasPrefix:kTemplateImagePrefix]) {
        ImageFile *imagefile = [[ImageFile alloc] initWithFilePath:templateDirectoryPath andFileName:file andDocumentsDirectory:docDirectory];
        [imageFiles addObject:imagefile];
      } else if ([file hasPrefix:kTemplateIndexFilename]) {
        // ignore index.html
      } else if ([file hasPrefix:kTemplateMarkerFilename]) {
        // ignore marker file
      } else if ([file hasPrefix:kTemplateJsonFilename]) {
        // ignore json file
      } else {
        CSSFile *cssfile = [[CSSFile alloc] initWithFilePath:templateDirectoryPath andFileName:file andDocumentsDirectory:docDirectory];
        [cssFiles addObject:cssfile];
      }
    }
  }
  return @[cssFiles, imageFiles];
}

- (void)listAllLocalFiles
{
  // Fetch directory path of document for local application.
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  // NSFileManager is the manager organize all the files on device.
  NSFileManager *manager = [NSFileManager defaultManager];
  // This function will return all of the files' Name as an array of NSString.
  NSArray *files = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
  // Log the Path of document directory.
  NSLog(@"Directory: %@", documentsDirectory);
  // For each file, log the name of it.
  for (NSString *file in files) {
    NSLog(@"File at: %@", file);
  }
}

- (void)createFileWithName:(NSString *)fileName
{
  NSString *filePath = [self getFilePath:fileName];
  
  NSFileManager *manager = [NSFileManager defaultManager];
  // 1st, This funcion could allow you to create a file with initial contents.
  // 2nd, You could specify the attributes of values for the owner, group, and permissions.
  // Here we use nil, which means we use default values for these attibutes.
  // 3rd, it will return YES if NSFileManager create it successfully or it exists already.
  if ([manager createFileAtPath:filePath contents:nil attributes:nil]) {
    NSLog(@"Created the File Successfully.");
  } else {
    NSLog(@"Failed to Create the File");
  }
}

- (void)deleteFileWithName:(NSString *)fileName
{
  NSString *filePath = [self getFilePath:fileName];
  
  NSFileManager *manager = [NSFileManager defaultManager];
  // Need to check if the to be deleted file exists.
  if ([manager fileExistsAtPath:filePath]) {
    NSError *error = nil;
    // This function also returnsYES if the item was removed successfully or if path was nil.
    // Returns NO if an error occurred.
    [manager removeItemAtPath:filePath error:&error];
    if (error) {
      NSLog(@"There is an Error: %@", error);
    }
  } else {
    NSLog(@"File %@ doesn't exists", fileName);
  }
}

- (void)readFileWithName:(NSString *)fileName
{
  NSString *filePath = [self getFilePath:fileName];
  
  // NSFileManager is the manager organize all the files on device.
  NSFileManager *manager = [NSFileManager defaultManager];
  if ([manager fileExistsAtPath:filePath]) {
    // Start to Read.
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:&error];
    NSLog(@"File Content: %@", content);
    
    if (error) {
      NSLog(@"There is an Error: %@", error);
    }
  } else {
    NSLog(@"File %@ doesn't exists", fileName);
  }
}

- (void)writeString:(NSString *)content toFile:(NSString *)fileName
{
  NSString *filePath = [self getFilePath:fileName];
  // NSFileManager is the manager organize all the files on device.
  NSFileManager *manager = [NSFileManager defaultManager];
  // Check if the file named fileName exists.
  if ([manager fileExistsAtPath:filePath]) {
    NSError *error = nil;
    // Since [writeToFile: atomically: encoding: error:] will overwrite all the existing contents in the file, you could keep the content temperatorily, then append content to it, and assign it back to content.
    // To use it, simply uncomment it.
    //            NSString *tmp = [[NSString alloc] initWithContentsOfFile:fileName usedEncoding:NSStringEncodingConversionAllowLossy error:nil];
    //            if (tmp) {
    //                content = [tmp stringByAppendingString:content];
    //            }
    // Write NSString content to the file.
    [content writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:&error];
    // If error happens, log it.
    if (error) {
      NSLog(@"There is an Error: %@", error);
    }
  } else {
    // If the file doesn't exists, log it.
    NSLog(@"File %@ doesn't exists", fileName);
  }
}

- (NSString *) getFilePath:(NSString *)fileName {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  // Have the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
  return filePath;
}

- (void)copyDirectory:(NSString *)directory
{
  BOOL success;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  fileManager.delegate = self;
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *newDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
  [fileManager createDirectoryAtPath:newDirectory withIntermediateDirectories:NO attributes:nil error:&error];
  
  NSString *writableDBPath = [newDirectory stringByAppendingPathComponent:directory];
  success = [fileManager fileExistsAtPath:writableDBPath];
  NSLog(@"%@",writableDBPath);
  if (!success )
  {
    // copy the files from
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:directory];
    
    //    NSLog(@"default path %@",defaultDBPath);
    success = [fileManager copyItemAtPath:defaultDBPath toPath:newDirectory error:&error];
    //    NSLog(@"%@",error.localizedDescription);
  } else {
    if (![[NSFileManager defaultManager] fileExistsAtPath:writableDBPath])
      [[NSFileManager defaultManager] createDirectoryAtPath:writableDBPath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

// delegate method
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
  if ([error code] == 516) {
    return YES;
  }
  return NO;
}

@end
