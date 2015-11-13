//
//  PublishViewController.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PublishViewController.h"
#import "TemplateTabBarController.h"
#import "Label.h"
#import "FileService.h"
#import "FileInfo.h"
#import "Constants.h"
#import "GitHubTree.h"
#import "GitHubRepo.h"
#import "GitHubUser.h"
#import <WebKit/WebKit.h>

@interface PublishViewController () <LabelDelegate, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet Label *ghPagesUrlLabel;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation PublishViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.ghPagesUrlLabel.delegate = self;
  self.ghPagesUrlLabel.text = kWebPageNotPublished;
  self.ghPagesUrlLabel.alpha = 0.35;
  
  self.webView = [[WKWebView alloc] init];
  self.webView.navigationDelegate = self;
  [self.stackView addArrangedSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.ghPagesUrlLabel.backgroundColor = [UIColor whiteColor];
  
  if (self.tabBarVC.userName) {
    [self enableNavigationItemButtons];
    
  } else {
    GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:self.tabBarVC.accessToken];
    [gitHubUser retrieveNameWithCompletion:^(NSError *error, NSString *name) {
      if (error) {
        // TODO - alert popover
        return;
      }
      
      [[NSUserDefaults standardUserDefaults] setObject:name forKey:kUserDefaultsUserNameKey];
      NSLog(@"User name saved to user defaults.");
      [self enableNavigationItemButtons];
    }];
  }
}

#pragma mark - IBActions, Selector Methods

- (void)publishButtonTapped {
  
  BOOL renameRequired = !self.tabBarVC.repoName || [self.tabBarVC.repoName isEqualToString:kUnpublishedRepoName];
  NSString *title = renameRequired ? @"Specify a descriptive name:" : nil;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  
  if (renameRequired) {
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder =  @"Web Page Repository";
    }];
  }
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Publish to GitHub" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    UITextField *textField = alert.textFields.firstObject;
    if (textField && textField.text.length > 0) {
      self.tabBarVC.repoName = textField.text;
      [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kUserDefaultsRepoNameKey];
    }
    [self publishToGitHub];
  }];
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)publishToGitHub {
  
  [self.busyIndicator startAnimating];
  
  if ([self.tabBarVC.repoNames containsObject:self.tabBarVC.repoName]) {
    [self republishRepo:self.tabBarVC.repoName];
  } else {
    [self publishAllFilesForRepo:self.tabBarVC.repoName];
  }
}

- (void)refreshButtonTapped {
  [self.webView reloadFromOrigin];
}

#pragma mark - Helper Methods

- (void)enableNavigationItemButtons {
  self.tabBarVC.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishButtonTapped)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)]];
}

- (NSURL *)ghPagesIndexHtmlFileURLforRepo:(NSString *)repoName {

  NSURL *ghPagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.github.io", self.tabBarVC.userName]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:kFileIndexName];
  ghPagesURL = [ghPagesURL URLByAppendingPathExtension:kFileHtmlExtension];

  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (NSURL *)ghPagesURLforRepo:(NSString *)repoName {

  NSURL *ghPagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.github.io", self.tabBarVC.userName]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName isDirectory:YES];
  
  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (void)loadWebView {
  [self.busyIndicator stopAnimating];
  NSURL *repoURL = [self ghPagesURLforRepo:self.tabBarVC.repoName];
  NSLog(@"WKWebView:loadRequest: [%@]", repoURL.absoluteString);
  [self.webView loadRequest:[NSURLRequest requestWithURL:repoURL]];
}

- (void)publishAllFilesForRepo:(NSString *)repoName {
  
  NSString *description = [NSString stringWithFormat:@"This repository created with a GitHub Pages branch for %@ (with HTML template %@ from Start Bootstrap) by iOS app InstaSite v1.0.", self.tabBarVC.userName, self.tabBarVC.templateDirectory];
 
  FileInfoMutableArray *initialFiles = [[FileInfoMutableArray alloc] initWithArray:[self initialFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  
  [self createRepoWithFiles:initialFiles user:self.tabBarVC.userName repo:repoName branch:kBranchName comment:description accessToken:self.tabBarVC.accessToken];
}

- (void)republishRepo:(NSString *)repoName {
  
  FileInfoMutableArray *changedFiles = [[FileInfoMutableArray alloc] initWithArray:[self changedFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  // TODO - rest of this method
}

- (FileInfoArray *)initialFileListForDirectory:(NSString *)directory rootDirectory:(NSString *)rootDirectory {
  FileService *fileService = [[FileService alloc] init];
  return [fileService enumerateFilesInDirectory:directory type:FileTypeHtml | FileTypeJpeg | FileTypeOther rootDirectory:rootDirectory];
}
- (FileInfoArray *)changedFileListForDirectory:(NSString *)directory rootDirectory:(NSString *)rootDirectory {
  FileService *fileService = [[FileService alloc] init];
  return [fileService enumerateFilesInDirectory:directory type:FileTypeHtml | FileTypeJpeg rootDirectory:rootDirectory];
}

- (void)createRepoWithFiles:(FileInfoArray *)files user:(NSString *)userName repo:(NSString *)repoName branch:(NSString *)branch comment:(NSString *)comment accessToken:(NSString *)accessToken {

  GitHubRepo *gitHubRepo = [[GitHubRepo alloc] initWithName:repoName accessToken:accessToken];
  [gitHubRepo createWithComment:comment completion:^(NSError *error) {

    if (error) {
      // TODO - alert popover
      return;
    }
    NSLog(@"Repo %@ created.", repoName);

    GitHubTree *gitHubTree = [[GitHubTree alloc] initWithFiles:files userName:userName repoName:repoName branch:branch accessToken:accessToken];
    [gitHubTree createAndCommitWithCompletion:^(NSError *error) {
      if (error) {
        // TODO - alert popover
        return;
      }
      NSLog(@"GitHub tree created for %@.", branch);
      self.ghPagesUrlLabel.text = !self.tabBarVC.repoName || [self.tabBarVC.repoName isEqualToString:kUnpublishedRepoName] ? nil : [[self ghPagesURLforRepo:self.tabBarVC.repoName] absoluteString];
      self.ghPagesUrlLabel.alpha = 1.0;
      
      double delay = 3.0;     // give GitHub pages some time to finish build
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{        
        [self loadWebView];
      });
    }];
  }];
}

#pragma mark - LabelDelegate

- (void)labelTouchBegin:(UILabel *)sender {
  
  if ([self.ghPagesUrlLabel.text isEqualToString:kWebPageNotPublished]) {
    return;
  }
  if (self.ghPagesUrlLabel.backgroundColor == [UIColor whiteColor]) {
    sender.backgroundColor = [self.view.tintColor colorWithAlphaComponent:0.25];
  } else {
    [UIPasteboard generalPasteboard].string = sender.text;
    sender.backgroundColor = [UIColor whiteColor];
  }
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

@end
