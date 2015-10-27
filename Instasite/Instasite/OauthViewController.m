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
#import <SSKeychain/SSKeychain.h>
#import <SafariServices/SafariServices.h>

@interface OauthViewController () <SFSafariViewControllerDelegate>

@property (strong,nonatomic) SFSafariViewController *safariVC;

@end

@implementation OauthViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBarHidden = YES;

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safariLogin:) name:kOpenURLnotificationName object:nil];
}

- (void)safariLogin:(NSNotification *)notification {
  // get the url from the auth callback
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
          // TODO - alert popover
          return;
        }
        
        [SSKeychain setPassword:[@"token " stringByAppendingString:token] forService:kSSKeychainService account:kSSKeychainAccount];
        NSLog(@"Token saved to keychain.");
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

- (IBAction)signupAction:(UIButton *)sender {
  NSURL *signupURL = [NSURL URLWithString:@"https://github.com/join"];
  self.safariVC = [[SFSafariViewController alloc] initWithURL:signupURL];
  self.safariVC.delegate = self;
  [self.navigationController pushViewController:self.safariVC animated:YES];
}

- (IBAction)loginAction:(UIButton *)sender {
  NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=instasite://oauth&scope=user,repo", kClientId]];
  self.safariVC = [[SFSafariViewController alloc] initWithURL:authURL];
  self.safariVC.delegate = self;
  [self.navigationController pushViewController:self.safariVC animated:YES];
}

#pragma mark - SFSafariViewControllerDelegate

//Called on Done Pressed
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [self popBackToCallingVC];
}

@end
