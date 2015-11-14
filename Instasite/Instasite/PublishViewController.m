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
#import "AppDelegate.h"
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
  
  if (![(AppDelegate *)[UIApplication sharedApplication].delegate accessToken]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[oauthStoryboard instantiateInitialViewController] animated:YES];
  }
  
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
  
  self.tabBarVC.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishButtonTapped)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)]];

  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;

  if (accessToken && !userName) {
    GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:[(AppDelegate *)[UIApplication sharedApplication].delegate accessToken]];
    [gitHubUser retrieveNameWithCompletion:^(NSError *error, NSString *name) {
      if (error) {
        // TODO - alert popover
        return;
      }
      
      [(AppDelegate *)[UIApplication sharedApplication].delegate setUserName:name];
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

  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;

  if ([self.tabBarVC.repoNames containsObject:self.tabBarVC.repoName]) {
    [self republishRepo:self.tabBarVC.repoName withUserName:userName usingAccessToken:accessToken];
  } else {
    [self publishAllFilesForRepo:self.tabBarVC.repoName withUserName:userName usingAccessToken:accessToken];
  }
}

- (void)refreshButtonTapped {
  [self.webView reloadFromOrigin];
}

#pragma mark - Helper Methods

- (NSURL *)ghPagesIndexHtmlFileURLforRepo:(NSString *)repoName withUserName:(NSString *)userName {

  NSURL *ghPagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.github.io", userName]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:kFileIndexName];
  ghPagesURL = [ghPagesURL URLByAppendingPathExtension:kFileHtmlExtension];

  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (NSURL *)ghPagesURLforRepo:(NSString *)repoName withUserName:(NSString *)userName {

  NSURL *ghPagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.github.io", userName]];
  ghPagesURL = [ghPagesURL URLByAppendingPathComponent:repoName isDirectory:YES];
  
  if (!ghPagesURL) {
    NSLog(@"Error! NSURL for: [%@]", ghPagesURL.absoluteString);
  }
  return ghPagesURL;
}

- (void)loadWebView {
  [self.busyIndicator stopAnimating];
  
  NSString *userName = [(AppDelegate *)[UIApplication sharedApplication].delegate userName];
  NSURL *repoURL = [self ghPagesURLforRepo:self.tabBarVC.repoName withUserName:userName];
  NSLog(@"WKWebView:loadRequest: [%@]", repoURL.absoluteString);
  [self.webView loadRequest:[NSURLRequest requestWithURL:repoURL]];
}

- (void)publishAllFilesForRepo:(NSString *)repoName withUserName:(NSString *)userName usingAccessToken:(NSString *)accessToken {
  
  NSString *description = [NSString stringWithFormat:@"This repository created with a GitHub Pages branch for %@ (with HTML template %@ from Start Bootstrap) by iOS app InstaSite v1.0.", userName, self.tabBarVC.templateDirectory];
 
  FileInfoMutableArray *initialFiles = [[FileInfoMutableArray alloc] initWithArray:[self initialFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  
  [self createRepoWithFiles:initialFiles user:userName repo:repoName branch:kBranchName comment:description accessToken:accessToken];
}

- (void)republishRepo:(NSString *)repoName withUserName:(NSString *)userName usingAccessToken:(NSString *)accessToken{
  
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
      self.ghPagesUrlLabel.text = !self.tabBarVC.repoName || [self.tabBarVC.repoName isEqualToString:kUnpublishedRepoName] ? nil : [[self ghPagesURLforRepo:self.tabBarVC.repoName withUserName:userName] absoluteString];
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
