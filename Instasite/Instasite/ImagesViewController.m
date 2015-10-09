//
//  ImagesViewController.m
//  Instasite
//
//  Created by mike davis on 10/3/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImagesViewController.h"
#import "ImageCell.h"
#import "HtmlTemplate.h"
#import "TemplateTabBarController.h"
#import "Constants.h"

static NSString *kCellId = @"ImageCell";

//<UICollectionViewDelegateFlowLayout>

@interface ImagesViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) NSArray *imageRefMarkers;

@end

@implementation ImagesViewController

- (NSArray *)imageRefMarkers {
  if (!_imageRefMarkers) {
    _imageRefMarkers = self.tabBarVC.templateMarkers[kImageRefArray];
  }
  return _imageRefMarkers;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  //self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:kCellId];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:true];

  self.navigationController.navigationBarHidden = NO;
  self.tabBarVC.navigationController.navigationBar.translucent = NO;
  self.tabBarVC.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
  self.tabBarVC.navigationItem.title = self.tabBarVC.repoName;
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)];
}

//- (void)viewDidLayoutSubviews {
//  [super viewDidLayoutSubviews];
//  [(ImageCollectionViewLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), kCellHeight)];
//}

#pragma mark - Selector Methods

- (void)addButtonTapped {
  [self actionSheetForImageSelection];
}

#pragma mark - Helper Methods

- (void)actionSheetForImageSelection {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select an Image" message:@"from" preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.barButtonItem = self.tabBarVC.navigationItem.rightBarButtonItem;

  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [alert addAction:action];
  }
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [alert addAction:action];
  }
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Saved Photos Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    [alert addAction:action];
  }
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:cancelAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)startImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
  UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
  imagePC.delegate = self;
  imagePC.allowsEditing = YES;
  imagePC.sourceType = sourceType;
  [self presentViewController:imagePC animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate, UINavigationControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  
  [picker dismissViewControllerAnimated:YES completion:nil];
  
  UIImage *image = info[UIImagePickerControllerEditedImage];
  [self.tabBarVC.images addObject:image];
  
  [self.collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSUInteger count = MAX(self.tabBarVC.images.count, self.imageRefMarkers.count);
  return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  
  if (indexPath.item < self.tabBarVC.images.count) {
    cell.placeholder = nil;
    cell.image = self.tabBarVC.images[indexPath.item];
  } else {
    cell.image = nil;
    cell.placeholder = [NSString stringWithFormat:@"%02lu", indexPath.item];
  }
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
  // TODO - currently the image is added as the lowest numbered "empty" cell
  [self addButtonTapped];
}

@end
