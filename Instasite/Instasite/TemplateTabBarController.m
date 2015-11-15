//
//  TemplateTabBarController.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateTabBarController.h"
#import "EditViewController.h"
#import "HtmlTemplate.h"
#import "UserInput.h"
#import "Constants.h"
#import "FileInfo.h"
#import "FileService.h"
#import "AppDelegate.h"

@interface TemplateTabBarController () <UITabBarControllerDelegate, NSFileManagerDelegate>

@property (strong, nonatomic) HtmlTemplateDictionary *htmlTemplates;

@end

@implementation TemplateTabBarController

- (UserInput *)userInput {
  if (!_userInput) {
    _userInput = [[UserInput alloc] init];
  }
  return _userInput;
}

- (ImagesDictionary *)images {
  if (!_images) {
    _images = [self loadImageDataFromFiles];
  }
  return _images;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.delegate = self;
  
  NSLog(@"Documents directory: %@", self.documentsDirectory);
  [self copyBundleTemplateDirectory];
  
  self.htmlTemplates = [self loadHtmlTemplatesAndCreateUserInput];

  NSData *jsonData = [self readJsonFile:[self jsonFileURL:kFileJsonName]];
  if (jsonData) {
    [self.userInput updateUsingJsonData:jsonData];
  }
  
  self.navigationItem.title = self.repoName;
}

#pragma mark - Helper Methods

- (NSURL *)htmlFileURL:(NSString *)fileName {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:fileName];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kFileHtmlExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithExtension];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithExtension);
  }
  return fileURL;
}

- (NSURL *)indexDirectoryURL {
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  
  NSURL *fileURL = [NSURL fileURLWithPath:workingDirectory isDirectory:YES];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", workingDirectory);
  }
  return fileURL;
}

- (NSURL *)jsonFileURL:(NSString *)fileName {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:fileName];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kFileJsonExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithExtension];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithExtension);
  }
  return fileURL;
}

// Copy the entire template folder from main bundle to the documents directory one time
-(void)copyBundleTemplateDirectory {
  
  FileService *fileService = [[FileService alloc] init];
  [fileService copyDirectory:self.templateDirectory overwrite:NO toDirectory:self.documentsDirectory];
}

-(HtmlTemplateDictionary *)loadHtmlTemplatesAndCreateUserInput {
  
  HtmlTemplateMutableDictionary *htmlTemplates = [[HtmlTemplateMutableDictionary alloc] init];
  FileService *fileService = [[FileService alloc] init];
  FileInfoArray *htmlTemplateFiles = [fileService enumerateFilesInDirectory:self.templateDirectory type:FileTypeTemplate rootDirectory:self.documentsDirectory];
  for (FileInfo *file in htmlTemplateFiles) {
    NSURL *fileURL = [NSURL fileURLWithPath:[file filepathIncludingLocalDirectory]];
    if (fileURL) {
      HtmlTemplate *template = [[HtmlTemplate alloc] initWithURL:fileURL];
      [template addInputGroupsToUserInput:self.userInput];
      htmlTemplates[file.name] = template;
    } else {
      NSLog(@"Error! NSURL:fileURLWithPath: [%@]", [file filepathIncludingLocalDirectory]);
    }
  }
  return htmlTemplates;
}

- (ImagesDictionary *)loadImageDataFromFiles {
  
  ImagesMutableDictionary *images = [[ImagesMutableDictionary alloc] init];
  NSString *imageDirectory = [self.templateDirectory stringByAppendingPathComponent:kFileImageDirectory];
  
  FileService *fileService = [[FileService alloc] init];
  FileInfoArray *imageFiles = [fileService enumerateFilesInDirectory:imageDirectory type:FileTypeJpeg rootDirectory:self.documentsDirectory];
  
  for (FileInfo *file in imageFiles) {
    
    NSLog(@"Loading image File: %@", file);
    NSData *imageData = [NSData dataWithContentsOfFile:[file filepathIncludingLocalDirectory]];
    
    if (imageData) {
      images[file.name] = imageData;
    }
  }
  return images;
}

- (BOOL)writeHtmlFile:(NSURL *)fileURL fromTemplate:(HtmlTemplate *)template usingGroups:(InputGroupDictionary *)groups {
  
  if ([template writeToURL:fileURL withInputGroups:groups]) {
    return YES;
  }
  return NO;
}

- (BOOL)writeJsonData:(NSData *)data fileURL:(NSURL *)fileURL {
  
  //NSLog(@"Writing file: %@", fileURL.relativePath);
  
  NSError *error;
  [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
  
  if (error) {
    NSLog(@"Error! NSData:writeToURL: [%@] error: %@", fileURL.relativeString, error.localizedDescription);
    return NO;
  }
  return YES;
}

- (NSData *)readJsonFile:(NSURL *)fileURL {
  
  //NSLog(@"Reading file: %@", fileURL.relativePath);
  
  NSError *error;
  NSData *jsonData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
  if (error) {
    //NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", fileURL, error.localizedDescription);
    return nil;
  }
  
  return jsonData;
}

- (void)writeImageFiles:(ImagesDictionary *)images {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  fileManager.delegate = self;    // prevent EXC_BAD_ACCESS when using removeItemAtPath
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kFileImageDirectory];
  
  // some templates have sample images in this directory
  //[fileManager removeItemAtPath:imagesDirectory error:nil];
  
  if (![fileManager fileExistsAtPath:imagesDirectory]) {
    NSError *error;
    [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
      NSLog(@"Error! Cannot create directory: [%@] error: %@", imagesDirectory, error.localizedDescription);
      return;
    }
  }
  
  for (NSString *fileName in images.allKeys) {
    
    NSData *data = images[fileName];
    
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:fileName];
    NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kFileImageExtension];
    
    //NSLog(@"Writing image file: %@", pathWithExtension);
    NSError *error;
    [data writeToFile:pathWithExtension options:NSDataWritingAtomic error:&error];
    if (error) {
      NSLog(@"Error! Cannot write image file: [%@] error: %@", pathWithExtension, error.localizedDescription);
      return;
    }
  }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
  
  if ([tabBarController.selectedViewController isKindOfClass:[EditViewController class]]) {
    EditViewController *editVC = tabBarController.selectedViewController;
    [editVC.lastTextEditingView endEditing:YES];
  }
  for (NSString *fileName in self.htmlTemplates.allKeys) {
    HtmlTemplate *template = self.htmlTemplates[fileName];
    [self writeHtmlFile:[self htmlFileURL:fileName] fromTemplate:template usingGroups:self.userInput.groups];
  }
  [self writeJsonData:[self.userInput createJsonData] fileURL:[self jsonFileURL:kFileJsonName]];
  [self writeImageFiles:self.images];

  return YES;
}

#pragma mark - NSFileManagerDelegate

// used if we need to overwrite a directory and files
// TODO - determine if we need this delegate method
-(BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
  NSLog(@"NSFileManager error: %lu", (long)error.code);
  if (error.code == NSFileWriteFileExistsError) {
    return YES;
  }
  return NO;
}

@end
