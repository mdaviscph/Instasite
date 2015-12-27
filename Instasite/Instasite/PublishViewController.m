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
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.ghPagesUrlLabel.delegate = self;
  self.ghPagesUrlLabel.text = @"";
  
  self.webView = [[WKWebView alloc] init];
  self.webView.navigationDelegate = self;
  [self.stackView addArrangedSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.ghPagesUrlLabel.backgroundColor = [UIColor whiteColor];
  
  self.tabBarVC.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(publishButtonTapped)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)]];

  [self signUpOrLogInIfNeeded];     // call in viewWillAppear in case previous viewWillAppear required signUp or LogIn
  
  [self getUserNameIfNeeded];
  
  [self updateUI];
}

#pragma mark - IBActions, Selector Methods

- (void)publishButtonTapped {
  
  BOOL renameRequired = !self.tabBarVC.repoName || [self.tabBarVC.repoName isEqualToString:kUnpublishedRepoName];
  NSString *title = renameRequired ? @"Specify a descriptive name:" : nil;
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  
  if (renameRequired) {
    self.tabBarVC.repoExists = GitHubRepoDoesNotExist;        // assume repo does not exist and we will catch existing repo in create call
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder =  @"Web Page Repository";
    }];
  }
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Publish to GitHub" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    NSString *repoName = self.tabBarVC.repoName;
    UITextField *textField = alert.textFields.firstObject;
    if (textField && textField.text.length > 0) {
      repoName = textField.text;
    }
    [self publishToGitHub:repoName];
  }];
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshButtonTapped {
  [self updateUI];
}

#pragma mark - Helper Methods

- (void)signUpOrLogInIfNeeded {
  if (![(AppDelegate *)[UIApplication sharedApplication].delegate accessToken]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[oauthStoryboard instantiateInitialViewController] animated:YES];
  }
}

- (void)getUserNameIfNeeded {
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;
  
  if (accessToken && !userName) {

    GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:[(AppDelegate *)[UIApplication sharedApplication].delegate accessToken]];
    [gitHubUser retrieveNameWithCompletion:^(NSError *error, NSString *name) {

      if (error) {
        [self showErrorAlertWithTitle:@"Authorization Error" usingError:error];
        
        if (error.code == ErrorCodeNotAuthorized) {
          [(AppDelegate *)[UIApplication sharedApplication].delegate setAccessToken:nil];
        }
        return;
      }
      
      [(AppDelegate *)[UIApplication sharedApplication].delegate setUserName:name];
    }];
  }
}

- (void)publishToGitHub:(NSString *)repoName {
  
  [self.busyIndicator startAnimating];
  
  BOOL shouldCreateRepo = self.tabBarVC.repoExists == GitHubRepoDoesNotExist;
  BOOL shouldCreatePages = self.tabBarVC.pagesStatus == GitHubPagesNone;
  BOOL shouldRepublishAllFiles = self.tabBarVC.pagesStatus == GitHubPagesError;
  BOOL shouldWait = self.tabBarVC.repoExists == GitHubResponsePending;
  
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  NSString *accessToken = appDelegate.accessToken;
  NSString *userName = appDelegate.userName;
  
  if (shouldCreateRepo || shouldCreatePages) {
    [self publishAllFilesForRepo:repoName withUserName:userName createRepo:shouldCreateRepo usingAccessToken:accessToken];
  } else if (!shouldWait) {
    [self republishRepo:repoName withUserName:userName allFiles:shouldRepublishAllFiles usingAccessToken:accessToken];
  } else {
    [self.busyIndicator stopAnimating];
  }
}

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
  
  if ([repoURL.absoluteString isEqualToString:self.webView.URL.absoluteString]) {
    [self.webView reloadFromOrigin];
    //NSLog(@"reloadFromOrigin");
  } else {
    [self.webView loadRequest:[NSURLRequest requestWithURL:repoURL]];
    //NSLog(@"loadRequest");
  }
}

- (void)publishAllFilesForRepo:(NSString *)repoName withUserName:(NSString *)userName createRepo:(BOOL)createRepo usingAccessToken:(NSString *)accessToken {
  
  NSString *comment = [NSString stringWithFormat:@"This repository created with a GitHub Pages branch for %@ (with HTML template %@ from Start Bootstrap) by iOS app InstaSite v1.0.", userName, self.tabBarVC.templateDirectory];
 
  FileInfoMutableArray *initialFiles = [[FileInfoMutableArray alloc] initWithArray:[self initialFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  
  if (createRepo) {
    [self createRepoWithFiles:initialFiles user:userName repo:repoName branch:kBranchName comment:comment accessToken:accessToken];
  } else {
    [self makeRepoWithFiles:initialFiles user:userName repo:repoName branch:kBranchName accessToken:accessToken];
  }
}

- (void)republishRepo:(NSString *)repoName withUserName:(NSString *)userName allFiles:(BOOL)allFiles usingAccessToken:(NSString *)accessToken{
  
  FileInfoMutableArray *files;
  if (allFiles) {
    files = [[FileInfoMutableArray alloc] initWithArray:[self initialFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  } else {
    files = [[FileInfoMutableArray alloc] initWithArray:[self changedFileListForDirectory:self.tabBarVC.templateDirectory rootDirectory:self.tabBarVC.documentsDirectory]];
  }
  
  [self updateRepoWithFiles:files user:userName repo:repoName branch:kBranchName accessToken:accessToken];
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

  GitHubRepo *gitHubRepo = [[GitHubRepo alloc] initWithName:repoName userName:userName accessToken:accessToken];
  [gitHubRepo createWithComment:comment completion:^(NSError *error, GitHubRepoTest exists) {

    self.tabBarVC.repoExists = exists;
    if (error) {
      if (exists == GitHubRepoExists) {
        [self showErrorAlertWithTitle:@"Create Repository Error" usingError:error];
      } else {
        [self showErrorAlertWithTitle:@"Create Repository Error" usingError:error];
      }
      [self.busyIndicator stopAnimating];
      return;
    }
    NSLog(@"Repo %@ created.", repoName);
    if (![repoName isEqualToString:self.tabBarVC.repoName]) {
      self.tabBarVC.repoName = repoName;
    }
    [self makeRepoWithFiles:files user:userName repo:repoName branch:branch accessToken:accessToken];
  }];
}

- (void)updateRepoWithFiles:(FileInfoArray *)files user:(NSString *)userName repo:(NSString *)repoName branch:(NSString *)branch accessToken:(NSString *)accessToken {
  
  GitHubTree *gitHubTree = [[GitHubTree alloc] initWithFiles:files userName:userName repoName:repoName branch:branch accessToken:accessToken];
  [gitHubTree updateAndCommitWithCompletion:^(NSError *error, GitHubPagesStatus status) {

    self.tabBarVC.pagesStatus = status;
    if (error) {
      [self showErrorAlertWithTitle:@"Republish Error" usingError:error];
      [self.busyIndicator stopAnimating];
      return;
    }
    NSLog(@"GitHub tree updated for %@.", branch);
    double delay = 3.0;     // give GitHub pages some time to finish build
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self updateUI];
    });
  }];
}

- (void)makeRepoWithFiles:(FileInfoArray *)files user:(NSString *)userName repo:(NSString *)repoName branch:(NSString *)branch accessToken:(NSString *)accessToken {
  
  GitHubTree *gitHubTree = [[GitHubTree alloc] initWithFiles:files userName:userName repoName:repoName branch:branch accessToken:accessToken];
  [gitHubTree makeAndCommitWithCompletion:^(NSError *error, GitHubPagesStatus status) {

    self.tabBarVC.pagesStatus = status;
    if (error) {
      [self showErrorAlertWithTitle:@"Publish Error" usingError:error];
      [self.busyIndicator stopAnimating];
      return;
    }
    NSLog(@"GitHub tree created for %@.", branch);
    double delay = 3.0;     // give GitHub pages some time to finish build
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self updateUI];
    });
  }];
}

- (void)updateUI {

  if (self.tabBarVC.pagesStatus == GitHubPagesNone) {
    [self.webView loadHTMLString:@"" baseURL:nil];
  } else {
    [self loadWebView];
  }
}

- (void)updateLabel {

  // TODO - better way to detect still waiting on build?
  if ([self.webView.title hasPrefix:@"Page not found"]) {
    self.ghPagesUrlLabel.alpha = 0.35;
    self.ghPagesUrlLabel.text = kWebPageBuildInProgress;
  } else if (self.webView.title.length == 0) {
    self.ghPagesUrlLabel.alpha = 0.35;
    self.ghPagesUrlLabel.text =  kWebPageNotPublished;
  } else {
    self.tabBarVC.pagesStatus = GitHubPagesBuilt;
    self.ghPagesUrlLabel.alpha = 1.0;
    self.ghPagesUrlLabel.text =  self.webView.URL.absoluteString;
  }
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

#pragma mark - LabelDelegate

- (void)labelTouchBegin:(UILabel *)sender {
  
  if (self.tabBarVC.pagesStatus != GitHubPagesBuilt) {
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
  [self updateLabel];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"Error! webView:didFailProvisionalNavigation: error: %@", error.localizedDescription);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  //NSLog(@"webView:didFinishNavigation:");
  [self updateLabel];
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
  //NSLog(@"webView:didCommitNavigation:");
}


@end
