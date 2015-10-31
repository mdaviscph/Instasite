//
//  TemplateTabBarController.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateTabBarController.h"
#import "HtmlTemplate.h"
#import "InputGroup.h"
#import "InputCategory.h"
#import "Constants.h"
#import "FileInfo.h"
#import "FileService.h"
#import <SSKeychain/SSKeychain.h>

@interface TemplateTabBarController () <UITabBarControllerDelegate>

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

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.delegate = self;

  if (!self.accessToken) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[oauthStoryboard instantiateInitialViewController] animated:YES];
  }
  
  NSLog(@"Documents directory: %@", self.documentsDirectory);
  [self copyBundleTemplateDirectory];
  
  self.templateCopy = [[HtmlTemplate alloc] initWithURL:[self templateHtmlURL]];
  self.inputGroups = [self.templateCopy createInputGroups];
  NSData *jsonData = [self readJsonFile:[self jsonFileURL]];
  if (jsonData) {
    [self updateGroupsFromJsonData:jsonData inputGroups:self.inputGroups];
  }
}

#pragma mark - Helper Methods

- (NSURL *)indexFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateIndexFilename];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kTemplateIndexExtension];
  
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

- (NSURL *)templateFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateMarkerFilename];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kTemplateMarkerExtension];
  
  NSURL *fileURL = [NSURL fileURLWithPath:pathWithExtension];
  if (!fileURL) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithExtension);
  }
  return fileURL;
}

- (NSURL *)jsonFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateJsonFilename];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kTemplateJsonExtension];
  
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

- (BOOL)writeHtmlFile:(NSURL *)fileURL usingGroups:(InputGroupDictionary *)groups {
  
  if ([self.templateCopy writeToURL:fileURL withInputGroups:groups]) {
    return YES;
  }
  return NO;
}

- (NSData *)jsonDataFromGroups:(InputGroupDictionary *)groups {
 
  // TODO - class to encapsulate self.inputGroups and this code as a method
  NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
  NSMutableArray *jsonGroupArray = [[NSMutableArray alloc] init];
  
  for (InputGroup *group in groups.allValues) {
    [jsonGroupArray addObject:[group createJson]];
  }
  jsonDictionary[@"groups"] = jsonGroupArray;
  
  NSError *error;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
  if (error) {
    NSLog(@"NSJSONSerialization:dataWithJSONObject: error: %@", error.localizedDescription);
    //[AlertPopover alert: kErrorJSONSerialization withNSError: error controller: nil completion: nil];
  }

  return jsonData;
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

- (void)updateGroupsFromJsonData:(NSData *)data inputGroups:(InputGroupDictionary *)groups {
  
  NSError *error;
  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  if (error) {
    NSLog(@"NSJSONSerialization:JSONObjectWithData: error: %@", error.localizedDescription);
    //[AlertPopover alert: kErrorJSONSerialization withNSError: error controller: nil completion: nil];
  }

  // TODO - class to encapsulate self.inputGroups and this code
  NSArray *jsonGroupArray = jsonDictionary[@"groups"];
  for (NSDictionary *jsonGroupDictionary in jsonGroupArray) {
    
    NSString *groupName = jsonGroupDictionary[@"name"];
    NSArray *jsonCategoryArray = jsonGroupDictionary[@"categories"];
    for (NSDictionary *jsonCategoryDictionary in jsonCategoryArray) {
      
      NSString *categoryName = jsonCategoryDictionary[@"name"];
      NSDictionary *fieldDictionary = jsonCategoryDictionary[@"fields"];
      for (NSString *fieldName in fieldDictionary.allKeys) {
        NSString *text = fieldDictionary[fieldName];
        
        InputGroup *group = self.inputGroups[groupName];
        InputCategoryDictionary *categories = group.categories;
        InputCategory *category = categories[categoryName];
        
        [category setFieldText:text forName:fieldName];
      }
    }
  }
}

- (void)writeImageFiles {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImageDirectory];
  
  [fileManager removeItemAtPath:imagesDirectory error:nil];
  //if (![fileManager fileExistsAtPath:imagesDirectory isDirectory:nil]) {
  NSError *error;
  [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
  if (error) {
    NSLog(@"Error! Cannot create directory: [%@] error: %@", imagesDirectory, error.localizedDescription);
    return;
  }
  
  for (NSString *fileName in self.images.allKeys) {
    
    NSData *data = self.images[fileName];
    
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:fileName];
    NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kTemplateImageExtension];
    
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
  
  [self writeHtmlFile:self.indexHtmlURL usingGroups:self.inputGroups];
  [self writeJsonData:[self jsonDataFromGroups:self.inputGroups] fileURL:self.userJsonURL];
  [self writeImageFiles];

  return YES;
}

@end
