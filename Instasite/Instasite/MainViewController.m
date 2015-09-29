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
#import "Constants.h"

static NSString *kCellId = @"cellId";
@interface MainViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *templateDirectories;
@property (nonatomic, strong) NSArray *imageNames;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
  // TODO - read this list from the bundle directory
  self.templateDirectories = @[@"startbootstrap-one-page-wonder-1.0.3",
                               @"startbootstrap-agency-1.0-2.4",
                               @"startbootstrap-freelancer-1.0.3",
                               @"startbootstrap-creative-1.0.1",
                               @"startbootstrap-clean-blog-1.0.3"];
  self.imageNames = @[@"one-page-wonder",@"agency",@"freelancer",@"creative",@"clean-blog"];

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

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:true];
  self.navigationController.navigationBarHidden = YES;
}


-(void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [(MPSkewedParallaxLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), kCellHeight)];
}

// TODO - determine this list from the bundle directory somehow
- (NSString *)titleForIndex:(NSInteger)index {
  NSString *text = nil;
  switch (index - 1) {
    case 0:
      text = @"ONE PAGE WONDER\n startbootstrap";
      break;
    case 1:
      text = @"AGENCY\n startbootstrap";
      break;
    case 2:
      text = @"FREELANCER\n startbootstrap";
      break;
    case 3:
      text = @"CREATIVE\n startbootstrap";
      break;
    case 4:
      text = @"CLEAN BLOG\n startbootstrap";
      break;
    default:
      break;
  }
  
  return text;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.templateDirectories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger index = indexPath.item % self.templateDirectories.count + 1;
  MPSkewedCell* cell = (MPSkewedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  cell.image = [UIImage imageNamed: self.imageNames[indexPath.row]];
  cell.text = [self titleForIndex:index];
  
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  NSLog(@"template directory: %@", self.templateDirectories[indexPath.item]);
  TemplateTabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateTabBarController"];
  tabBarVC.documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  tabBarVC.templateDirectory = self.templateDirectories[indexPath.item];
  [self.navigationController pushViewController:tabBarVC animated:YES];
}


@end
