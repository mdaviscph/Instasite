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

@end

@implementation DisplayTemplateViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = NO;

  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  WKWebView *webView = [[WKWebView alloc]initWithFrame: self.view.frame];
  [self.view addSubview: webView];
  webView.navigationDelegate = self;
  
  NSURL *htmlUrl = [self displayTemplate];
  [webView loadFileURL:htmlUrl allowingReadAccessToURL:htmlUrl];
}

- (NSURL *)displayTemplate {
  
  if (!self.tabBarVC.templateDirectory) {
    return nil;
  }
  // no working filename means that this the first time they have chosen this template
  // and we need to create the working file. the first time we will use the bootstrap
  // version so it shows placeholder-like text. once they start editing and save we will
  // switch to showing the working version which may include some instasite markers.
  if (!self.tabBarVC.workingFilename) {

    self.tabBarVC.workingHtml = [[HtmlTemplate alloc] initWithPath:kTemplateMarkerFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
  }
  
  return [HtmlTemplate genURL:kTemplateIndexFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
}

// Copy the entire template folder from main bundle to the documents directory
-(void)copyDirectoryToDocumentsDir {
  FileManager *fm = [[FileManager alloc]init];
  [fm copyDirectory: self.tabBarVC.templateDirectory];
  
}

#pragma mark - Helper Methods
- (BOOL)createWorkingFile:(NSString *)filename {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  if ([self.tabBarVC.workingHtml writeToFile:filename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, kTemplateIndexFiletype, self.tabBarVC.templateDirectory);
  return NO;
}

@end
