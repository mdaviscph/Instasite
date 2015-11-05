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
#import "GitHubUser.h"
#import "Repo.h"
#import "Constants.h"
#import <SSKeychain/SSKeychain.h>

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
  
  NSString *accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  if (accessToken) {
    [self getExistingReposUsing:accessToken];
  }
  
  // TODO - read this list from the bundle directory
  self.templateDirectories = @[@"startbootstrap-1-col-portfolio-1.0.3",
                               @"startbootstrap-one-page-wonder-1.0.3",
                               @"startbootstrap-landing-page-1.0.4",
                               @"startbootstrap-agency-1.0-2.4",
                               @"startbootstrap-freelancer-1.0.3",
                               @"startbootstrap-creative-1.0.1",
                               @"startbootstrap-clean-blog-1.0.3"];
  self.imageNames = @[@"1-col-portfolio",@"one-page-wonder",@"landing-page",@"agency",@"freelancer",@"creative",@"clean-blog"];
  self.titles = @[@"ONE COLUMN PORTFOLIO",@"ONE PAGE WONDER",@"LANDING PAGE",@"AGENCY",@"FREELANCER",@"CREATIVE",@"CLEAN BLOG"];

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
  [super viewWillAppear:YES];
  self.navigationItem.title = @"InstaSite";
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [(MPSkewedParallaxLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), kCellHeight)];
}

#pragma mark - Helper Methods

// TODO - check for access_token?
- (void)getExistingReposUsing:(NSString *)accessToken {
  
  GitHubUser *gitHubUser = [[GitHubUser alloc] initWithAccessToken:accessToken];
  [gitHubUser retrieveReposWithCompletion:^(NSError *error, NSArray *repos) {

    if (error) {
      // TODO - alert popover
      NSLog(@"Error in GitHubUser:retrieveReposWithBranch: error: %@", error.localizedDescription);
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
  if (section == 1 && self.repos.count > 0) {
      return self.repos.count;
  } else {
    return self.templateDirectories.count;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MPSkewedCell* cell = (MPSkewedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  
  if (indexPath.section == 1 && self.repos.count > 0) {
    cell.image = [UIImage imageNamed:self.imageNames[0]];     // TODO - retrieve this from...
    cell.text = self.repos[indexPath.item];
  } else {
    cell.image = [UIImage imageNamed:self.imageNames[indexPath.item]];
    cell.text = self.titles[indexPath.item];
  }
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

  TemplateTabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateTabBarVC"];

  tabBarVC.documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  
  // TODO - this will get straigtened out when we redo this VC
  NSMutableSet *repoNames = [[NSMutableSet alloc] init];
  for (Repo *repo in self.repos) {
    [repoNames addObject:repo.name];
  }
  tabBarVC.repoNames = [[NSSet alloc] initWithArray:repoNames.allObjects];
  
  if (indexPath.section == 1 && self.repos.count > 0) {
    tabBarVC.repoName = [self.repos[indexPath.item] name];
    tabBarVC.templateDirectory = self.templateDirectories[0];     // TODO - retrieve this from...
  } else {
    tabBarVC.repoName = kUnpublishedName;
    tabBarVC.templateDirectory = self.templateDirectories[indexPath.item];
  }
  
  NSLog(@"template directory: %@", tabBarVC.templateDirectory);
  [self.navigationController pushViewController:tabBarVC animated:YES];
}

@end
