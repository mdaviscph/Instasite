//
//  ImagesViewController.m
//  Instasite
//
//  Created by mike davis on 10/3/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImagesViewController.h"
#import "ImageCell.h"
#import "SegmentedControl.h"
#import "TemplateTabBarController.h"
#import "InputGroup.h"
#import "InputCategory.h"
#import "InputField.h"
#import "Constants.h"

static NSString *kCellId = @"ImageCell";

//<UICollectionViewDelegateFlowLayout>

@interface ImagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet SegmentedControl *groupSegmentedControl;
@property (weak, nonatomic) IBOutlet SegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *sortedGroupKeys;
@property (strong, nonatomic) NSArray *sortedCategoryKeys;
@property (strong, nonatomic) NSArray *sortedImageKeys;

@property (strong, nonatomic) NSString *selectedGroupName;
@property (strong, nonatomic) NSString *selectedCategoryName;
@property (strong, nonatomic) NSString *selectedImageName;


@property (strong, nonatomic) TemplateTabBarController *tabBarVC;

@end

@implementation ImagesViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];

  //self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:kCellId];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  
  self.groupSegmentedControl.delegate = self;
  self.categorySegmentedControl.delegate = self;
  
  self.sortedGroupKeys = [self sortGroupKeys:self.tabBarVC.inputGroups];
  self.selectedGroupName = self.sortedGroupKeys[0];
  [self.groupSegmentedControl resetWithTitles:self.sortedGroupKeys];
  
  [self reloadGroup];
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

#pragma mark - IBActions, Selector Methods

- (IBAction)groupSegmentedControlChange:(SegmentedControl *)sender {
  [self switchToGroup:sender.selectedSegmentIndex];
}
- (IBAction)categorySegmentedControlChange:(SegmentedControl *)sender {
  [self switchToCategory:sender.selectedSegmentIndex];
}

- (void)importImageForImageName:(NSString *)name {
  [self actionSheetForImageSelection:name];
}

#pragma mark - Helper Methods

- (NSArray *)sortGroupKeys:(InputGroupDictionary *)groups {
  return [groups keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputGroup *)obj1 tag] > [(InputGroup *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
}
- (NSArray *)sortCategoryKeys:(InputCategoryDictionary *)groups {
  return [groups keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputCategory *)obj1 tag] > [(InputCategory *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
}

- (void)reloadGroup {
  [self switchToGroup:-1];
}
- (void)reloadCategory {
  [self switchToCategory:-1];
}

- (void)switchToGroup:(NSInteger)index {
  self.selectedGroupName = index >= 0 ? self.sortedGroupKeys[index] : self.selectedGroupName;
  InputGroup *group = self.tabBarVC.inputGroups[self.selectedGroupName];
  self.sortedCategoryKeys = [self sortCategoryKeys:group.categories];
  self.selectedCategoryName = self.sortedCategoryKeys[0];
  [self.categorySegmentedControl resetWithTitles:self.sortedCategoryKeys];
  [self switchToCategory:0];
}
- (void)switchToCategory:(NSInteger)index {
  self.selectedCategoryName = index >= 0 ? self.sortedCategoryKeys[index] : self.selectedCategoryName;
  self.sortedImageKeys = [self sortImageFieldsInGroup:self.selectedGroupName andCategory:self.selectedCategoryName];
  [self.collectionView reloadData];
}

- (NSArray *)sortImageFieldsInGroup:(NSString *)groupName andCategory:(NSString *)categoryName {
  
  NSMutableArray *imageFields = [[NSMutableArray alloc] init];
  
  InputGroup *group = self.tabBarVC.inputGroups[groupName];
  InputCategoryDictionary *categories = group.categories;
  InputCategory *category = categories[categoryName];
  InputFieldDictionary *fields = category.fields;

  NSArray *sortedFieldKeys = [fields keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputField *)obj1 tag] > [(InputField *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
  
  for (NSString *fieldName in sortedFieldKeys) {
    
    InputField *field = fields[fieldName];
    if (field.type == FieldIMG) {
      [imageFields addObject:field.name];
    }
  }
  return imageFields;
}

- (void)actionSheetForImageSelection:(NSString *)name {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
  self.tabBarVC.images[self.selectedImageName] = imageData;
  
  NSString *filepath = [kTemplateImageDirectory stringByAppendingPathComponent:self.selectedImageName];
  NSString *pathWithExtension = [filepath stringByAppendingPathExtension:kTemplateImageExtension];
  
  InputGroup *group = self.tabBarVC.inputGroups[self.selectedGroupName];
  InputCategoryDictionary *categories = group.categories;
  InputCategory *category = categories[self.selectedCategoryName];

  [category setFieldText:pathWithExtension forName:self.selectedImageName];
  
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
  NSUInteger count = self.sortedImageKeys.count;
  return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
  
  NSString *imageName = self.sortedImageKeys[indexPath.item];
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
  
  self.selectedImageName = self.sortedImageKeys[indexPath.item];
  [self importImageForImageName:self.selectedImageName];
}

#pragma mark - SegmentedControlDelegate

// this protocol is defined in SegmentedControl.h and used so we can force editing to
// end, prior to the segnmentedControl index changing, for any textViews since there is
// no textViewShouldReturn delegate method
- (void)segmentedControlIndexWillChange:(UISegmentedControl *)sender {
}

@end
