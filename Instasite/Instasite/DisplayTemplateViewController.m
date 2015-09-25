//
//  DisplayTemplateViewController.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "DisplayTemplateViewController.h"
#import "TemplateTabBarController.h"
#import <WebKit/WebKit.h>
#import "HtmlTemplate.h"
#import "Constants.h"
#import "FileManager.h"

@interface DisplayTemplateViewController () <WKNavigationDelegate>

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) WKWebView *webView;

@end;

@implementation DisplayTemplateViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = NO;

  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.webView = [[WKWebView alloc]initWithFrame: self.view.frame];
  [self.view addSubview: self.webView];
  self.webView.navigationDelegate = self;

  [self copyDirectoryToDocumentsDir];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  NSURL *htmlUrl = [self displayTemplate];
  [self.webView loadFileURL:htmlUrl allowingReadAccessToURL:htmlUrl];
}

#pragma mark - Helper Methods

- (NSURL *)displayTemplate {
  
  if (!self.tabBarVC.templateDirectory) {
    return nil;
  }
  
  if (!self.tabBarVC.workingHtml) {
    self.tabBarVC.workingHtml = [[HtmlTemplate alloc] initWithPath:kTemplateMarkerFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
  }

  return [HtmlTemplate genURL:kTemplateIndexFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
}

// Copy the entire template folder from main bundle to the documents directory
-(void)copyDirectoryToDocumentsDir {
  FileManager *fm = [[FileManager alloc]init];
  [fm copyDirectory: self.tabBarVC.templateDirectory];  
}

- (BOOL)createWorkingFile:(NSString *)filename {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  if ([self.tabBarVC.workingHtml writeToFile:filename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, kTemplateIndexFiletype, self.tabBarVC.templateDirectory);
  return NO;
}

@end
