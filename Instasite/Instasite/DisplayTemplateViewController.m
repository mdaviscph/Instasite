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
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.webView = [[WKWebView alloc]initWithFrame: self.view.frame];
  [self.view addSubview: self.webView];
  self.webView.navigationDelegate = self;

  [self copyDirectoryToDocumentsDir];

  [self readHtmlTemplate];
  
  NSURL *htmlURL = [self indexHtmlURL];
  [self.webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = YES;
  [self.webView reload];
//  [self.webView reloadFromOrigin];
}

#pragma mark - Helper Methods

- (NSURL *)indexHtmlURL {
  return [HtmlTemplate genURL:kTemplateIndexFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
}

- (void)readHtmlTemplate {
  self.tabBarVC.templateCopy = [[HtmlTemplate alloc] initWithPath:kTemplateMarkerFilename ofType:kTemplateIndexFiletype inDirectory:self.tabBarVC.templateDirectory];
}

// Copy the entire template folder from main bundle to the documents directory one time
-(void)copyDirectoryToDocumentsDir {
  FileManager *fm = [[FileManager alloc] init];
  [fm copyDirectory:self.tabBarVC.templateDirectory overwrite:NO];
}

@end
