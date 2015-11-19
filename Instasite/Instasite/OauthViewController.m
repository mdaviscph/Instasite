//
//  OauthViewController.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "OauthViewController.h"
#import "Keys.h"
#import "Constants.h"
#import "GitHubAccessToken.h"
#import "AppDelegate.h"
#import <SafariServices/SafariServices.h>

@interface OauthViewController () <SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@property (strong,nonatomic) SFSafariViewController *safariVC;

@end

@implementation OauthViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBarHidden = YES;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safariLogin:) name:kOpenURLnotificationName object:nil];
}

- (void)safariLogin:(NSNotification *)notification {
  // get the url from the OAuth callback
  NSURL *openURL = notification.userInfo[kOpenURLdictionaryKey];
  //NSLog(@"safariLogin: %@", openURL);
  
  if (openURL) {
    NSString *code;
    NSURLComponents *components = [NSURLComponents componentsWithURL:openURL resolvingAgainstBaseURL:NO];
    for (NSURLQueryItem *queryItem in components.queryItems) {
      if ([queryItem.name isEqualToString:@"code"]) {
        code = queryItem.value;
      }
    }
    if (code) {
      GitHubAccessToken *gitHubToken = [[GitHubAccessToken alloc] initWithCode:code clientId:kClientId clientSecret:kClientSecret];
      [gitHubToken retrieveTokenWithCompletion:^(NSError *error, NSString *token) {
        
        if (error) {
          [self showErrorAlertWithTitle:@"Authorization Error" usingError:error];
          return;
        }
        
        NSString *accessToken = [@"token " stringByAppendingString:token];
        [(AppDelegate *)[UIApplication sharedApplication].delegate setAccessToken:accessToken];
      }];
    }
  }
  [self popBackToCallingVC];
}

- (void)popBackToCallingVC {

  // TODO - detect that signup is happening so we can go directly to a login without returning

  // this didn't work..
  //[self.navigationController popViewControllerAnimated:YES];
  //[self.navigationController popViewControllerAnimated:YES];
  // this also didn't work..
  //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  //UIViewController *tabBarVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TemplateTabBarVC"];
  //[self.navigationController popToViewController:tabBarVC animated:YES];
  
  [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)signUpButtonTapped:(UIButton *)sender {
  
  NSString *message = @"InstaSite uses GitHub.com's project repositories and GitHub Pages free hosting of public web pages. GitHub offers free accounts for users and organizations working on open source projects, as well as paid accounts for users and organizations that need private repositories.";
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.signUpButton;
  alert.popoverPresentationController.sourceRect = self.signUpButton.bounds;
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    NSURL *signupURL = [NSURL URLWithString:@"https://github.com/join"];
    self.safariVC = [[SFSafariViewController alloc] initWithURL:signupURL];
    self.safariVC.delegate = self;
    [self.navigationController pushViewController:self.safariVC animated:YES];
  }];
  
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)logInButtonTapped:(UIButton *)sender {

  NSString *message = @"InstaSite requires \"repo scope\" in order to create and write to GitHub repositories. GitHub defines this scope as: Grants read/write access to code, commit statuses, collaborators, and deployment statuses for public and private repositories and organizations.";
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.logInButton;
  alert.popoverPresentationController.sourceRect = self.logInButton.bounds;
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=instasite://oauth&scope=repo", kClientId]];
    self.safariVC = [[SFSafariViewController alloc] initWithURL:authURL];
    self.safariVC.delegate = self;
    [self.navigationController pushViewController:self.safariVC animated:YES];
  }];
  
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelButtonTapped:(UIButton *)sender {
  [self popBackToCallingVC];
}

#pragma mark - Helper Methods

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

#pragma mark - SFSafariViewControllerDelegate

// Called on Done Pressed
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [self popBackToCallingVC];
}

@end
