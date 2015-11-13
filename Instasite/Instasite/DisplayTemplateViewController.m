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

@interface DisplayTemplateViewController () <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) WKWebView *webView;

@end;

@implementation DisplayTemplateViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.webView = [[WKWebView alloc]init];
  self.webView.navigationDelegate = self;
  [self.stackView addArrangedSubview:self.webView];
  
  [self.webView loadFileURL:[self.tabBarVC htmlFileURL:kFileIndexName ] allowingReadAccessToURL:[self.tabBarVC indexDirectoryURL]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.tabBarVC.navigationItem.rightBarButtonItems = nil;
  
  [self.webView reloadFromOrigin];
}

#pragma mark - Helper Methods

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"Error! webView:didFailNavigation: error: %@", error.localizedDescription);
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"Error! webView:didFailProvisionalNavigation: error: %@", error.localizedDescription);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  //NSLog(@"webView:didFinishNavigation:");
}

@end
