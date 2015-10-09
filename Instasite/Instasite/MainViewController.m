//
//  MainViewController.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "MainViewController.h"
#import <MPSkewed/MPSkewedParallaxLayout.h>
#import <MPSkewed/MPSkewedCell.h>
#import "TemplateTabBarController.h"
#import "GitHubService.h"
#import "RepoInfo.h"
#import "Constants.h"

static NSString *kCellId = @"MainCell";
static NSUInteger kSpaceBetweenCells = 10;
static NSUInteger kCellHeight = 250;

@interface MainViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *templateDirectories;
@property (strong, nonatomic) NSArray *imageNames;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *repos;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self getExistingRepos];
  
  // TODO - read this list from the bundle directory
  self.templateDirectories = @[@"startbootstrap-one-page-wonder-1.0.3",
                               @"startbootstrap-agency-1.0-2.4",
                               @"startbootstrap-freelancer-1.0.3",
                               @"startbootstrap-creative-1.0.1",
                               @"startbootstrap-clean-blog-1.0.3"];
  self.imageNames = @[@"one-page-wonder",@"agency",@"freelancer",@"creative",@"clean-blog"];
  self.titles = @[@"ONE PAGE WONDER",@"AGENCY",@"FREELANCER",@"CREATIVE",@"CLEAN BLOG"];

  MPSkewedParallaxLayout *layout = [[MPSkewedParallaxLayout alloc] init];
  layout.lineSpacing = kSpaceBetweenCells;
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.backgroundColor = [UIColor whiteColor];
  [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:kCellId];
  [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:true];
  self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [(MPSkewedParallaxLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), kCellHeight)];
}

#pragma mark - Helper Methods

// TODO - check for access_token
- (void)getExistingRepos {
  [GitHubService.sharedInstance getReposWithCompletion:^(NSError *error, NSArray *repos) {
    if (error) {
      // TODO - alert popover
      NSLog(@"Error in getReposWithCompletion: %@", error.localizedDescription);
    }
    self.repos = repos;
    [self.collectionView reloadData];
  }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.repos.count > 0 ? 2 : 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if (section == 0 && self.repos.count > 0) {
      return self.repos.count;
  } else {
    return self.templateDirectories.count;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MPSkewedCell* cell = (MPSkewedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  
  if (indexPath.section == 0 && self.repos.count > 0) {
    RepoInfo *repo = self.repos[indexPath.item];
    cell.image = [UIImage imageNamed:self.imageNames[0]];     // TODO - retrieve this from...
    cell.text = repo.name;
  } else {
    cell.image = [UIImage imageNamed:self.imageNames[indexPath.item]];
    cell.text = self.titles[indexPath.item];
  }
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

  TemplateTabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateTabBarController"];

  tabBarVC.documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  
  if (indexPath.section == 0 && self.repos.count > 0) {
    RepoInfo *repo = self.repos[indexPath.item];
    tabBarVC.repoName = repo.name;
    tabBarVC.templateDirectory = self.templateDirectories[0];     // TODO - retrieve this from...
  } else {
    tabBarVC.templateDirectory = self.templateDirectories[indexPath.item];
  }
  
  NSLog(@"template directory: %@", tabBarVC.templateDirectory);
  [self.navigationController pushViewController:tabBarVC animated:YES];
}

@end
