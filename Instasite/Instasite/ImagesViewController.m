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
@property (strong, nonatomic) NSString *selectedImageFileName;

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
  [super viewWillAppear:YES];

  self.navigationController.navigationBarHidden = NO;
  self.navigationController.navigationBar.translucent = NO;
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
  self.tabBarVC.navigationItem.title = self.tabBarVC.repoName;
  self.tabBarVC.navigationItem.rightBarButtonItem = nil;
  self.tabBarVC.navigationItem.leftBarButtonItem = nil;
}

//- (void)viewDidLayoutSubviews {
//  [super viewDidLayoutSubviews];
//  [(ImageCollectionViewLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.bounds), kCellHeight)];
//}

#pragma mark - Selector Methods

- (void)importImageFor:(NSString *)name {
  [self actionSheetForImageSelection:name];
}

#pragma mark - Helper Methods

- (void)actionSheetForImageSelection:(NSString *)name {
  NSString *title = [@"photo for " stringByAppendingString:name];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.barButtonItem = self.tabBarVC.navigationItem.rightBarButtonItem;

  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [alert addAction:action];
  }
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [alert addAction:action];
  } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
  NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

  [self.tabBarVC.images setObject:imageData forKey:self.selectedImageFileName];
  
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
  NSUInteger count = self.imageRefMarkers.count;
  return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  
  NSString *imageName = [NSString stringWithFormat:@"image%02lu", indexPath.item+1];
  NSData *imageData = self.tabBarVC.images[imageName];
  if (imageData) {
    cell.placeholder = nil;
    cell.image = [UIImage imageWithData:imageData];
  } else {
    cell.image = nil;
    cell.placeholder = imageName;
  }
  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
  self.selectedImageFileName = [NSString stringWithFormat:@"image%02lu", indexPath.item+1];
  [self importImageFor:self.selectedImageFileName];
}

@end
