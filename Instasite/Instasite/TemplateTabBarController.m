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
#import "GitHubRepo.h"
#import "Repo.h"
#import "AppDelegate.h"

@interface TemplateTabBarController () <UITabBarControllerDelegate, NSFileManagerDelegate>

@property (strong, nonatomic) HtmlTemplateDictionary *htmlTemplates;

@end

@implementation TemplateTabBarController

- (void)setRepoName:(NSString *)repoName {
  _repoName = repoName;
  [[NSUserDefaults standardUserDefaults] setObject:repoName forKey:kUserDefaultsRepoNameKey];
  self.navigationItem.title = repoName;
}

- (UserInput *)userInput {
  if (!_userInput) {
    _userInput = [[UserInput alloc] init];
  }
  return _userInput;
}

// lazy load user's image files for template
- (ImagesDictionary *)images {
  if (!_images) {
    NSError *error;
    _images = [self loadImageDataFromFilesInTemplateDirectory:self.templateDirectory withDocumentsDirectory:self.documentsDirectory error:&error];
    if (error) {
      [self showErrorAlertWithTitle:@"Read Error" usingError:error];
    }
  }
  return _images;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.delegate = self;
  
  NSLog(@"Documents directory: %@", self.documentsDirectory);
  if (![self copyBundleTemplateDirectory]) {
    NSError *error = [self ourErrorWithOurCode:ErrorCodeWritingUserData description:@"Unable to copy template directory." message:@"Please retry operation or restart application."];
    [self showErrorAlertWithTitle:@"Copy Error" usingError:error];
  }
  
  NSError *htmlTemplateError;
  self.htmlTemplates = [self loadHtmlTemplatesAndCreateUserInputFromTemplateDirectory:self.templateDirectory withDocumentsDirectory:self.documentsDirectory error:&htmlTemplateError];
  if (htmlTemplateError) {
    [self showErrorAlertWithTitle:@"Read Error" usingError:htmlTemplateError];
  }
  
  NSData *jsonData = [self readJsonFile:[self jsonFileURL:kFileJsonName]];
  if (jsonData) {
    if (![self.userInput updateUsingJsonData:jsonData]) {
      NSError *error = [self ourErrorWithOurCode:ErrorCodeReadingUserData description:@"Unable to read your saved data." message:@"Please retry operation or restart application."];
      [self showErrorAlertWithTitle:@"Read Error" usingError:error];
    }
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.repoExists = GitHubRepoDoesNotExist;
  self.pagesStatus = GitHubPagesNone;
  if (self.repoName && ![self.repoName isEqualToString:kUnpublishedRepoName]) {
    [self checkRepoAndPagesStatus:self.repoName];
  }
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
-(BOOL)copyBundleTemplateDirectory {
  
  FileService *fileService = [[FileService alloc] init];
  return [fileService copyDirectory:self.templateDirectory overwrite:NO toDirectory:self.documentsDirectory];
}

-(HtmlTemplateDictionary *)loadHtmlTemplatesAndCreateUserInputFromTemplateDirectory:(NSString *)templateDirectory withDocumentsDirectory:(NSString *)documentsDirectory error:(NSError **)outError {
  
  HtmlTemplateMutableDictionary *htmlTemplates = [[HtmlTemplateMutableDictionary alloc] init];
  FileService *fileService = [[FileService alloc] init];
  FileInfoArray *htmlTemplateFiles = [fileService enumerateFilesInDirectory:templateDirectory type:FileTypeTemplate rootDirectory:documentsDirectory];
  for (FileInfo *file in htmlTemplateFiles) {
    BOOL success = NO;
    NSURL *fileURL = [NSURL fileURLWithPath:[file filepathIncludingLocalDirectory]];
    if (fileURL) {
      HtmlTemplate *template = [[HtmlTemplate alloc] initWithURL:fileURL];
      success = [template addInputGroupsToUserInput:self.userInput];
      htmlTemplates[file.name] = template;
    } else {
      NSLog(@"Error! NSURL:fileURLWithPath: [%@]", [file filepathIncludingLocalDirectory]);
    }
    if (!success) {
      if (outError) {
        *outError = [self ourErrorWithOurCode:ErrorCodeReadingProjectData description:@"Error reading HTML file." message:@"Please retry operation or restart application."];
      }
    }
  }
  return htmlTemplates;
}

- (ImagesDictionary *)loadImageDataFromFilesInTemplateDirectory:(NSString *)templateDirectory withDocumentsDirectory:(NSString *)documentsDirectory error:(NSError **)outError {
  
  ImagesMutableDictionary *images = [[ImagesMutableDictionary alloc] init];
  NSString *imageDirectory = [templateDirectory stringByAppendingPathComponent:kFileImageDirectory];
  
  FileService *fileService = [[FileService alloc] init];
  FileInfoArray *imageFiles = [fileService enumerateFilesInDirectory:imageDirectory type:FileTypeJpeg rootDirectory:documentsDirectory];
  
  for (FileInfo *file in imageFiles) {
    
    //NSLog(@"Loading image File: %@", file);
    NSData *imageData = [NSData dataWithContentsOfFile:[file filepathIncludingLocalDirectory]];
    
    if (imageData) {
      images[file.name] = imageData;
    } else {
      NSLog(@"Error! NSData:dataWithContentsOfFile: [%@]", [file filepathIncludingLocalDirectory]);
      if (outError) {
        *outError = [self ourErrorWithOurCode:ErrorCodeReadingProjectData description:@"Unable to read HTML file." message:@"Please retry operation."];
      }
    }
  }
  return images;
}

- (BOOL)writeHtmlFile:(NSURL *)fileURL fromTemplate:(HtmlTemplate *)template usingGroups:(InputGroupDictionary *)groups {
  
  return [template writeToURL:fileURL withInputGroups:groups];
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

// note: json file will not exist for first use of new template
- (NSData *)readJsonFile:(NSURL *)fileURL {
  
  //NSLog(@"Reading file: %@", fileURL.relativePath);
  
  NSError *error;
  NSData *jsonData = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
  if (error) {
    //NSLog(@"Warning! NSData:dataWithContentsOfFile: [%@] error: %@", fileURL, error.localizedDescription);
    return nil;
  }
  
  return jsonData;
}

- (BOOL)writeImageFiles:(ImagesDictionary *)images {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  fileManager.delegate = self;    // prevent EXC_BAD_ACCESS when using removeItemAtPath
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kFileImageDirectory];
  
  // TODO - remove image files no longer used
  // some templates have sample images in this directory
  //[fileManager removeItemAtPath:imagesDirectory error:nil];
  
  if (![fileManager fileExistsAtPath:imagesDirectory]) {
    NSError *error;
    [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
      NSLog(@"Error! Cannot create directory: [%@] error: %@", imagesDirectory, error.localizedDescription);
      return NO;
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
      return NO;
    }
  }
  return YES;
}

- (void)checkRepoAndPagesStatus:(NSString *)repoName {
  
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;
  
  if (accessToken && userName && repoName) {
    self.repoExists = GitHubResponsePending;
    GitHubRepo *gitHubRepo = [[GitHubRepo alloc] initWithName:repoName userName:userName accessToken:accessToken];
    [gitHubRepo retrieveExistenceWithCompletion:^(NSError *error, GitHubRepoTest exists) {

      self.repoExists = exists;
      if (error) {
        [self showErrorAlertWithTitle:@"Check Repository Error" usingError:error];
        return;
      }
      if (exists == GitHubRepoDoesNotExist) {
        NSLog(@"Repo %@ does not exist.", repoName);
        return;
      }
      NSLog(@"Repo %@ exists.", repoName);
      [self checkPagesBuildStatus];
    }];
  }
}

- (void)checkPagesBuildStatus {
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;
  
  if (accessToken && userName && self.repoExists == GitHubRepoExists) {

    // Note: GitHub seems to delay a return of "built" 15 to 60 seconds so we shouldn't
    // use this after publish to determine when to load webView.
    GitHubRepo *gitHubRepo = [[GitHubRepo alloc] initWithName:self.repoName userName:userName accessToken:accessToken];
    [gitHubRepo retrievePagesStatusWithCompletion:^(NSError *error, GitHubPagesStatus status) {

      self.pagesStatus = status;
      if (error) {
        [self showErrorAlertWithTitle:@"Check GitHub Pages Error" usingError:error];
        return;
      }
      if (status == GitHubPagesNone) {
        NSLog(@"GitHub Pages does not exist.");
        return;
      }
      NSLog(@"GitHub Pages %@", status == GitHubPagesBuilt ? @"ready." : @"build in progress.");
    }];
  }
}

// create error to include project specific code and retry suggestion, if any
- (NSError *)ourErrorWithOurCode:(NSInteger)ourCode description:(NSString *)description message:(NSString *)message {
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
  userInfo[NSLocalizedDescriptionKey] = description;
  userInfo[NSLocalizedRecoverySuggestionErrorKey] = message;
  return [[NSError alloc] initWithDomain:kErrorDomain code:ourCode userInfo:userInfo];
}

- (void)showErrorAlertWithTitle:(NSString *)title usingError:(NSError *)error {
  
  NSString *detail = error.userInfo[NSLocalizedDescriptionKey];
  NSString *recovery = error.userInfo[NSLocalizedRecoverySuggestionErrorKey];
  NSString *message = recovery ? [NSString stringWithFormat:@"%@\n%@", detail, recovery] : detail;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  UIAlertAction *action1 = [UIAlertAction actionWithTitle: @"Ok" style:UIAlertActionStyleDefault handler:nil];
  [alert addAction:action1];
  
  [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
  
  if ([tabBarController.selectedViewController isKindOfClass:[EditViewController class]]) {
    EditViewController *editVC = tabBarController.selectedViewController;
    [editVC.lastTextEditingView endEditing:YES];
  }
  for (NSString *fileName in self.htmlTemplates.allKeys) {
    HtmlTemplate *template = self.htmlTemplates[fileName];
    if (![self writeHtmlFile:[self htmlFileURL:fileName] fromTemplate:template usingGroups:self.userInput.groups]) {
      [self showErrorAlertWithTitle:@"Save Error" usingError:[self ourErrorWithOurCode:ErrorCodeWritingUserData description:@"Unable to save your HTML file." message:@"Please retry operation or restart application."]];
      return NO;
    }
  }
  NSData *jsonData = [self.userInput createJsonData];
  if (!jsonData) {
    [self showErrorAlertWithTitle:@"Save Error" usingError:[self ourErrorWithOurCode:ErrorCodeWritingUserData description:@"Unable to save your data." message:@"Please retry operation or restart application."]];
    return NO;
  }
  if (![self writeJsonData:jsonData fileURL:[self jsonFileURL:kFileJsonName]]) {
    [self showErrorAlertWithTitle:@"Save Error" usingError:[self ourErrorWithOurCode:ErrorCodeWritingUserData description:@"Unable to save your data." message:@"Please retry operation or restart application."]];
    return NO;
  }
  if (![self writeImageFiles:self.images]) {
    [self showErrorAlertWithTitle:@"Save Error" usingError:[self ourErrorWithOurCode:ErrorCodeWritingUserData description:@"Unable to save your image files." message:@"Please retry operation or restart application."]];
    return NO;
  }
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
