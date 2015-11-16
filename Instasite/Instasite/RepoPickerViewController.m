//
//  RepoPickerViewController.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoPickerViewController.h"
#import "TemplateTabBarController.h"
#import "RepoCell.h"
#import "Constants.h"
#import "GitHubUser.h"
#import "Repo.h"

static NSString *kCellId = @"RepoCell";

@interface RepoPickerViewController ()

@property (strong, nonatomic) NSArray *repos;

@end

@implementation RepoPickerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.tableView registerClass:[RepoCell class] forCellReuseIdentifier:kCellId];
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  self.navigationItem.title = @"GitHub Repositories";
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self getExistingRepos];
}

#pragma mark - Selector Methods

- (void)cancelTapped {
  if ([self.delegate respondsToSelector:@selector(repoPickerDidCancel:)]) {
    [self.delegate repoPickerDidCancel:self];
  }
}

#pragma mark - Helper Methods

- (void)getExistingRepos {
  
  GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:self.accessToken];
  [gitHubUser retrieveReposWithCompletion:^(NSError *error, NSArray *repos) {
    
    if (error) {
      // TODO - alert popover
      if ([self.delegate respondsToSelector:@selector(repoPicker:didFailWithError:)]) {
        [self.delegate repoPicker:self didFailWithError:error];
      }
    }
    self.repos = repos;
    [self.tableView reloadData];
  }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.repos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RepoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
  cell.repo = self.repos[indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RepoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if ([self.delegate respondsToSelector:@selector(repoPicker:didFinishPickingWithName:)]) {
    [self.delegate repoPicker:self didFinishPickingWithName:cell.repo.name];
  }
}

@end
