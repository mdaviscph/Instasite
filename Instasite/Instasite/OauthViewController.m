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
#import "GitHubService.h"
#import "AppDelegate.h"
#import <SSKeychain/SSKeychain.h>
#import <SafariServices/SafariServices.h>

@interface OauthViewController () <SFSafariViewControllerDelegate>

@property (strong,nonatomic) SFSafariViewController *safariVC;

@end

@implementation OauthViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safariLogin:) name:kCloseSafariViewControllerNotification object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)safariLogin:(NSNotification *)notification {
  // get the url form the auth callback
  NSURL *url = notification.object;
  NSLog(@"%@", url);
  [GitHubService exchangeCodeInURL:url];
  
  [self.safariVC dismissViewControllerAnimated:true completion:nil];
  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
  UIViewController *vc = [mainStoryboard instantiateInitialViewController];
  
  appDelegate.window.rootViewController = vc;
  
}
- (IBAction)testGetUser:(UIButton *)sender {
//  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testimage" ofType:@"jpg"];
//  [GitHubService pushImagesToGithub:@"testimage3.jpg" imagePath:filePath forRepo:@"TestFromApi"];
}

- (IBAction)signupAction:(UIButton *)sender {
  NSURL *signupURL = [NSURL URLWithString:@"https://github.com/join"];
  self.safariVC = [[SFSafariViewController alloc] initWithURL:signupURL];
  self.safariVC.delegate = self;
  [self presentViewController:self.safariVC animated:true completion:nil];
}

- (IBAction)loginAction:(UIButton *)sender {
  NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=instasite://oauth&scope=user,repo", kClientId]];
  self.safariVC = [[SFSafariViewController alloc] initWithURL:authURL];
  self.safariVC.delegate = self;
  [self presentViewController:self.safariVC animated:true completion:nil];
}

#pragma mark - SFSafariViewControllerDelegate

//Called on Done Pressed
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  [controller dismissViewControllerAnimated:true completion:nil];
}

@end
