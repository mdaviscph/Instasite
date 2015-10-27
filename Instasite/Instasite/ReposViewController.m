//
//  ReposViewController.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ReposViewController.h"
#import "TemplateTabBarController.h"
#import "RepoCell.h"
#import "Constants.h"
#import "GitHubUser.h"

static NSString *kCellId = @"RepoCell";

@interface ReposViewController ()

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) NSArray *repoNames;

@end

@implementation ReposViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView registerClass:[RepoCell class] forCellReuseIdentifier:kCellId];
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self getExistingRepos];
  
  self.navigationController.navigationBarHidden = NO;
  self.navigationController.navigationBar.translucent = NO;
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)];
  self.tabBarVC.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - Selector Methods

- (void)addButtonTapped {
  // TODO - create a new repo
}

#pragma mark - Helper Methods

- (void)getExistingRepos {
  
  GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:self.tabBarVC.accessToken];
  [gitHubUser retrieveReposWithBranch:kBranchName completion:^(NSError *error, NSArray *repoNames) {
    
    if (error) {
      // TODO - alert popover
      NSLog(@"Error in GitHubUser:retrieveReposWithBranch: error: %@", error.localizedDescription);
    }
    self.repoNames = repoNames;
    [self.tableView reloadData];
  }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.repoNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RepoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
  cell.repo = self.repoNames[indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // TODO - use this existing repo
}

@end
