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
#import "DisplayTemplateViewController.h"

static NSString *kCellId = @"cellId";
@interface MainViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic) NSInteger pathItem;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.navigationController.navigationBarHidden = YES;
  self.imageNames = @[@"one-page-wonder",@"agency",@"freelancer",@"creative",@"clean-blog"];
  MPSkewedParallaxLayout *layout = [[MPSkewedParallaxLayout alloc] init];
  layout.lineSpacing = 10;
  layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 250);
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.backgroundColor = [UIColor whiteColor];
  [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:kCellId];
  [self.view addSubview:self.collectionView];
}

-(void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [(MPSkewedParallaxLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 300)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"ShowTemplate"]) {
    NSLog(@"shows the template");
    DisplayTemplateViewController* displayTempVC = (DisplayTemplateViewController*)segue.destinationViewController;
    displayTempVC.pathItem = self.pathItem;
  }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger index = indexPath.item % 5 + 1;
  MPSkewedCell* cell = (MPSkewedCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  cell.image = [UIImage imageNamed: self.imageNames[indexPath.row]];
  cell.text = [self titleForIndex:index];
  
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  NSLog(@" %zd",indexPath.item);
  self.pathItem = indexPath.item;
  [self performSegueWithIdentifier:@"ShowTemplate" sender:self];
}


@end
