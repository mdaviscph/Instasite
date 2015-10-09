//
//  PublishViewController.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PublishViewController.h"
#import "TemplateTabBarController.h"
#import "GitHubService.h"
#import "FileManager.h"
#import "FileInfo.h"
#import "UserInfo.h"
#import "CommitJson.h"
#import "Constants.h"

@interface PublishViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *repoNameTextField;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) UserInfo *user;

@end

@implementation PublishViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;

  self.repoNameTextField.delegate = self;
  self.repoNameTextField.text = self.tabBarVC.repoName;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.tabBarVC.navigationController.navigationBarHidden = NO;
  self.tabBarVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped)];

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

  FileInfo *indexFile = [[FileInfo alloc] initWithFileName:kTemplateIndexFilename fileType:kTemplateIndexFiletype relativePath:nil templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
  FileInfo *jsonFile = [[FileInfo alloc] initWithFileName:kTemplateJsonFilename fileType:kTemplateJsonFiletype relativePath:nil templateDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
  FileManager *fileManager = [[FileManager alloc] init];
  NSArray *allFiles = [fileManager enumerateFilesInDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];

  // publish if new name or rename of repo
  NSString *repoName = self.repoNameTextField.text;
  if (![self.tabBarVC.repoName isEqualToString:repoName]) {
    NSString *description = [NSString stringWithFormat:@"This repository created with a GitHub Pages branch for %@ with HTML template %@ from Start Bootstrap using InstaSite v1.0.", self.user.name, self.tabBarVC.templateDirectory];
    [GitHubService.sharedInstance createRepo:repoName description:description completion:^(NSError *error) {
      if (error) {
        // TODO - Alert popover
        return;
      }
      self.tabBarVC.repoName = repoName;
      [GitHubService.sharedInstance getRefs:repoName completion:^(NSError *error, CommitJson *commit) {
        if (error) {
          // TODO - Alert popover
          return;
        }
        NSLog(@"SHA: %@", commit.objectSHA);
        [GitHubService.sharedInstance createBranchForRepo:repoName parentSHA:commit.objectSHA completion:^(NSError *error) {
          if (error) {
            // TODO - Alert popover
            return;
          }
          [GitHubService.sharedInstance pushIndexHtmlFile:indexFile forRepo:repoName completion:^(NSError *error) {
            if (error) {
              // TODO - Alert popover
              return;
            }
            [GitHubService.sharedInstance pushJsonFile:jsonFile forRepo:repoName completion:^(NSError *error) {
              if (error) {
                // TODO - Alert popover
                return;
              }
              
              NSMutableArray *supportingFiles = [[NSMutableArray alloc] initWithArray:allFiles.firstObject];
              [GitHubService.sharedInstance pushSupportingFiles:supportingFiles forRepo:repoName completion:^(NSError *error) {
                if (error) {
                  // TODO - Alert popover
                  return;
                }
                // success
              }];
            }];
          }];
        }];
      }];
    }];
  }
}

- (void)composeButtonTapped {
  NSString *repoName = self.repoNameTextField.text;
  [GitHubService.sharedInstance getRefs:repoName completion:^(NSError *error, CommitJson *commit) {
    if (error) {
      // TODO - Alert popover
      return;
    }
    NSLog(@"SHA: %@", commit.objectSHA);
    [GitHubService.sharedInstance createBranchForRepo:repoName parentSHA:commit.objectSHA completion:^(NSError *error) {
      if (error) {
        // TODO - Alert popover
        return;
      }
    }];
  }];
}

#pragma mark - UITextFieldDelegate
  
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
