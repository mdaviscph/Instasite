//
//  PublishViewController.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PublishViewController.h"
#import "TemplateTabBarController.h"
#import <WebKit/WebKit.h>
#import "GitHubService.h"
#import "FileManager.h"
#import "FileInfo.h"
#import "UserInfo.h"
#import "CommitJson.h"
#import "FileJson.h"
#import "Constants.h"

@interface PublishViewController () <UITextFieldDelegate, WKNavigationDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *repoNameTextField;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UserInfo *user;

@end

@implementation PublishViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;

  self.repoNameTextField.delegate = self;
  self.repoNameTextField.text = self.tabBarVC.repoName;
  
  self.webView = [[WKWebView alloc] init];
  self.webView.navigationDelegate = self;
  [self.stackView addArrangedSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.tabBarVC.navigationController.navigationBarHidden = NO;
  self.tabBarVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)];

  self.user = [GitHubService.sharedInstance getUserInfo:^(NSError *error, UserInfo *user) {
    if (error) {
      // TODO - alert popover
      NSLog(@"Error in getUserInfo: %@", error.localizedDescription);
    } else {
      [user saveToUserDefaults];
      self.user = user;
      self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishButtonTapped)];
    }
  }];
  if (self.user) {
    self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishButtonTapped)];
  } else {
    self.tabBarVC.navigationItem.rightBarButtonItem = nil;
  }
}

#pragma mark - Selector Methods

- (void)publishButtonTapped {
  
  if (![GitHubService.sharedInstance isAuthorized]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    UIViewController *oauthVC = [oauthStoryboard instantiateInitialViewController];
    [self.navigationController pushViewController:oauthVC animated:YES];
  }
  
  [self.busyIndicator startAnimating];
  
  // publish if new name or rename of repo, else re-publish
  // TODO - check if user types in name of existing repo
  NSString *repoName = self.repoNameTextField.text;
  if (![self.tabBarVC.repoName isEqualToString:repoName]) {
    [self publishAllFilesForRepo:repoName];
    self.tabBarVC.repoName = repoName;
  } else {
    [self republishRepo:repoName];
  }
}

- (void)refreshButtonTapped {
  [self.webView reloadFromOrigin];
}

#pragma mark - Helper Methods

- (NSURL *)ghPagesIndexHtmlFileURLforRepo:(NSString *)repoName {

  NSURL *ghPagesURL = [NSURL URLWithString:[GitHubService.sharedInstance ghPagesUrl]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:kTemplateIndexFilename];
  ghPagesURL = [ghPagesURL URLByAppendingPathExtension:kTemplateIndexFiletype];

  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (NSURL *)ghPagesURLforRepo:(NSString *)repoName {

  NSURL *ghPagesURL = [NSURL URLWithString:[GitHubService.sharedInstance ghPagesUrl]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName isDirectory:YES];
  
  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (void)loadWebView {
  [self.busyIndicator stopAnimating];
  NSString *repoName = self.repoNameTextField.text;
  [self.webView loadRequest:[NSURLRequest requestWithURL:[self ghPagesURLforRepo:repoName]]];
}

- (void)publishAllFilesForRepo:(NSString *)repoName {
  
  FileInfo *indexFile = [[FileInfo alloc] initWithFileName:kTemplateIndexFilename extension:kTemplateIndexFiletype type:IndexHtml relativePath:nil templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
  FileManager *fileManager = [[FileManager alloc] init];
  NSArray *allFiles = [fileManager enumerateFilesInDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
  
  NSMutableArray *supportingFiles = [[NSMutableArray alloc] init];
  [supportingFiles addObject:indexFile];    // index file must be first in array so it is last to be PUT to github, otherwise github pages won't build
  [supportingFiles addObjectsFromArray:allFiles.firstObject];     // include files: CSS, font, user input data as JSON, etc.
  [supportingFiles addObjectsFromArray:allFiles.lastObject];      // include image files

  NSString *description = [NSString stringWithFormat:@"This repository created with a GitHub Pages branch for %@ with HTML template %@ from Start Bootstrap using InstaSite v1.0.", self.user.name, self.tabBarVC.templateDirectory];
  
  [GitHubService.sharedInstance createRepo:repoName description:description completion:^(NSError *error) {
    if (error) {
      // TODO - alert popover
      return;
    }
    self.tabBarVC.repoName = repoName;
    [GitHubService.sharedInstance pushFiles:supportingFiles forRepo:repoName completion:^(NSError *error, NSArray *remainingFiles) {
      if (error && remainingFiles) {
        NSLog(@"(%lu) Files not pushed: %@", remainingFiles.count, remainingFiles);
        [supportingFiles removeAllObjects];
        [supportingFiles addObjectsFromArray:remainingFiles];
        [GitHubService.sharedInstance pushFiles:supportingFiles forRepo:repoName completion:^(NSError *error, NSArray *remainingFiles) {
          if (error && remainingFiles) {
            NSLog(@"(%lu) Files not pushed: %@", remainingFiles.count, remainingFiles);
            [supportingFiles removeAllObjects];
            [supportingFiles addObjectsFromArray:remainingFiles];
            [GitHubService.sharedInstance pushFiles:supportingFiles forRepo:repoName completion:^(NSError *error, NSArray *remainingFiles) {
              if (error && remainingFiles) {
                // TODO - alert popover
                NSLog(@"(%lu) Files not pushed: %@", remainingFiles.count, remainingFiles);
              } else {
                NSLog(@"AAA");
              }
            }];
          } else {
            NSLog(@"BBB");
          }
        }];
      } else {
        NSLog(@"CCC");
        [self loadWebView];
      }
    }];
  }];
}

- (void)republishRepo:(NSString *)repoName {
  
  // TODO - also push json file and image files
  FileInfo *indexFile = [[FileInfo alloc] initWithFileName:kTemplateIndexFilename extension:kTemplateIndexFiletype type:IndexHtml relativePath:nil templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
  [GitHubService.sharedInstance getFile:indexFile forRepo:repoName completion:^(NSError *error, FileJson *file) {
    if (error) {
      // TODO - alert popover
      return;
    }
    [GitHubService.sharedInstance pushIndexHtmlFile:indexFile forRepo:repoName withSha:file.sha completion:^(NSError *error) {
      if (error) {
        // TODO - alert popover
        return;
      } else {
        //NSURL *ghPagesURL = [self ghPagesIndexHtmlFileURLforRepo:repoName];
        [self loadWebView];
      }
    }];
  }];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

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

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.webView;
}

@end
