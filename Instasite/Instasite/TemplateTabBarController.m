//
//  TemplateTabBarController.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateTabBarController.h"
#import "HtmlTemplate.h"
#import "Constants.h"
#import "FileInfo.h"
#import "FileService.h"
#import <SSKeychain/SSKeychain.h>

@interface TemplateTabBarController ()

// public readonly properties
@property (strong, readwrite, nonatomic) NSURL *indexHtmlURL;
@property (strong, readwrite, nonatomic) NSURL *indexHtmlDirectoryURL;
@property (strong, readwrite, nonatomic) NSURL *templateHtmlURL;
@property (strong, readwrite, nonatomic) NSURL *userJsonURL;
// public readonly properties
@property (strong, readwrite, nonatomic) NSString *accessToken;      // retrieved from Keychain
@property (strong, readwrite, nonatomic) NSString *userName;         // retrieved from UserDefaults

@end

@implementation TemplateTabBarController

- (NSURL *)indexHtmlURL {
  if (!_indexHtmlURL) {
    _indexHtmlURL = [self indexFileURL];
  }
  return _indexHtmlURL;
}
- (NSURL *)indexHtmlDirectoryURL {
  if (!_indexHtmlDirectoryURL) {
    _indexHtmlDirectoryURL = [self indexDirectoryURL];
  }
  return _indexHtmlDirectoryURL;
}
- (NSURL *)templateHtmlURL {
  if (!_templateHtmlURL) {
    _templateHtmlURL = [self templateFileURL];
  }
  return _templateHtmlURL;
}
- (NSURL *)userJsonURL {
  if (!_userJsonURL) {
    _userJsonURL = [self jsonFileURL];
  }
  return _userJsonURL;
}

- (NSString *)accessToken {
  if (!_accessToken) {
    _accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  }
  return _accessToken;
}
- (NSString *)userName {
  if (!_userName) {
    _userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsNameKey];
  }
  return _userName;
}

- (NSMutableDictionary *)images {
  if (!_images) {
    _images = [[NSMutableDictionary alloc] init];
    [self loadImageDataFromFiles];
  }
  return _images;
}

- (HtmlTemplate *)templateCopy {
  if (!_templateCopy) {
    _templateCopy = [[HtmlTemplate alloc] initWithURL:[self templateHtmlURL]];
  }
  return _templateCopy;
}

- (InputGroupDictionary *)inputGroups {
  if (!_inputGroups) {
    _inputGroups = [self.templateCopy createInputGroups];
  }
  return _inputGroups;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (!self.accessToken) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[oauthStoryboard instantiateInitialViewController] animated:YES];
  }
  
  NSLog(@"Documents directory: %@", self.documentsDirectory);
  [self copyBundleTemplateDirectory];
  
  ///NSLog(@"Count of groups: %lu", self.inputGroups.count);
}

#pragma mark - Helper Methods

- (NSURL *)indexFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateIndexFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateIndexExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithType];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
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

- (NSURL *)templateFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateMarkerFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateMarkerExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithType];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return fileURL;
}

- (NSURL *)jsonFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateJsonFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateJsonExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithType];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return fileURL;
}

// Copy the entire template folder from main bundle to the documents directory one time
-(void)copyBundleTemplateDirectory {
  
  FileService *fileService = [[FileService alloc] init];
  [fileService copyDirectory:self.templateDirectory overwrite:NO toDirectory:self.documentsDirectory];
}

- (void)loadImageDataFromFiles {
  
  NSString *imageDirectory = [self.templateDirectory stringByAppendingPathComponent:kTemplateImageDirectory];
  
  FileService *fileService = [[FileService alloc] init];
  FileInfoArray *imageFiles = [fileService enumerateFilesInDirectory:imageDirectory rootDirectory:self.documentsDirectory];
  
  for (FileInfo *file in imageFiles) {
    
    NSLog(@"Loading image File: %@", file);
    NSData *imageData = [NSData dataWithContentsOfFile:[file filepathIncludingLocalDirectory]];
    
    if (imageData) {
      [self.images setObject:imageData forKey:file.name];
    }
  }
}

@end
