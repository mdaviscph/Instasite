//
//  SafariViewController.m
//  Instasite
//
//  Created by mike davis on 9/29/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "SafariViewController.h"
#import "HtmlTemplate.h"
#import "Constants.h"
#import "TemplateTabBarController.h"
@import SafariServices;

@interface SafariViewController () <SFSafariViewControllerDelegate>

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) SFSafariViewController *safariVC;

@end

@implementation SafariViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;

  NSURL *indexHtmlURL = [self indexHtmlURL];
//  self.safariVC = [[SFSafariViewController alloc] initWithURL:indexHtmlURL entersReaderIfAvailable:YES];
  self.safariVC.delegate = self;
  
  [self addChildViewController:self.safariVC];
  self.safariVC.view.frame = self.view.frame;
  [self.view addSubview:self.safariVC.view];
  [self.safariVC didMoveToParentViewController:self];
}

- (NSURL *)indexHtmlURL {
//  return [GitHubService fileURL:kTemplateIndexFilename type:kTemplateIndexFiletype templateDirectory:self.tabBarVC.templateDirectory self.tabBarVC.githubUserRepository];
  return nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = YES;
  //[self.safariVC reload];
}

#pragma mark - SFSafariViewControllerDelegate
  
//Called on Done Pressed
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  //[controller dismissViewControllerAnimated:true completion:nil];
}

@end
