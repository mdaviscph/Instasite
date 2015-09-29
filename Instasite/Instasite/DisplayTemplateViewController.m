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

  [self copyBundleTemplateDirectory];

  NSURL *templateURL = [self templateHtmlURL];
  self.tabBarVC.templateCopy = [[HtmlTemplate alloc] initWithURL:templateURL];
  
  NSURL *indexHtmlURL = [self indexHtmlURL];
  [self.webView loadFileURL:indexHtmlURL allowingReadAccessToURL:indexHtmlURL];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = YES;
  [self.webView reload];
}

#pragma mark - Helper Methods

- (NSURL *)indexHtmlURL {
  return [HtmlTemplate fileURL:kTemplateIndexFilename type:kTemplateIndexFiletype templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
}
- (NSURL *)templateHtmlURL {
  return [HtmlTemplate fileURL:kTemplateMarkerFilename type:kTemplateMarkerFiletype templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
}

// Copy the entire template folder from main bundle to the documents directory one time
-(void)copyBundleTemplateDirectory {
  FileManager *fileManager = [[FileManager alloc] init];
  [fileManager copyDirectory:self.tabBarVC.templateDirectory overwrite:NO documentsDirectory:self.tabBarVC.documentsDirectory];
}

@end
