//
//  OauthViewController.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "OauthViewController.h"
#import "Keys.h"
#import <SafariServices/SafariServices.h>

@interface OauthViewController () <SFSafariViewControllerDelegate>

@end

@implementation OauthViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)signupAction:(UIButton *)sender {
  NSURL *signupURL = [NSURL URLWithString:@"https://github.com/join"];
  SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:signupURL];
  safariVC.delegate = self;
  [self presentViewController:safariVC animated:true completion:nil];
}

- (IBAction)loginAction:(UIButton *)sender {
  NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=githubclient://oauth&scope=user,repo", kClientId]];
  SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:authURL];
  safariVC.delegate = self;
  [self presentViewController:safariVC animated:true completion:nil];
}

#pragma mark - SFSafariViewControllerDelegate


//Called on Done Pressed
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [controller dismissViewControllerAnimated:true completion:nil];
}

@end
