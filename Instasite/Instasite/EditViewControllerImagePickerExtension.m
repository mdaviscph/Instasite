//
//  EditViewControllerImagePickerExtension.m
//  Instasite
//
//  Created by mike davis on 9/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewControllerImagePickerExtension.h"
#import "EditViewController.h"
#import "TemplateInput.h"
#import "TemplateTabBarController.h"
#import "HtmlTemplate.h"
#import "Feature.h"
#import "Constants.h"

@implementation EditViewController (ImagePickerExtension)

- (void)actionSheetForImageSelection:(UIButton *)button {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select an Image" message:@"from" preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.view;
  alert.popoverPresentationController.sourceRect = button.frame;
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
  NSData *data = UIImageJPEGRepresentation(image, 1.0);
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *imageFile = [NSString stringWithFormat:@"%@%ld", kTemplateImagePrefix, self.selectedFeature + 1];
  NSString *workingDirectory = [self.tabBarVC.documentsDirectory stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImagesDirectory];
  NSString *filepath = [imagesDirectory stringByAppendingPathComponent:imageFile];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:@"jpg"];

  if (![fileManager fileExistsAtPath:imagesDirectory isDirectory:nil]) {
    NSError *error;
    [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
      NSLog(@"Error! Cannot create directory: [%@] error: %@", imagesDirectory, error.localizedDescription);
      return;
    }
  }

  NSLog(@"Writing file: %@", pathWithType);
  if (![fileManager createFileAtPath:pathWithType contents:data attributes:nil]) {
    NSLog(@"Error! Cannot create file: %@", pathWithType);
    return;
  }
  
  NSString *relativeFilepath = [kTemplateImagesDirectory stringByAppendingPathComponent:imageFile];
  NSString *relativePathWithType = [relativeFilepath stringByAppendingPathExtension:@"jpg"];
  [self.tabBarVC.templateCopy insertImageReference:self.selectedFeature imageSource:relativePathWithType];
  Feature *feature = self.userInput.features[self.selectedFeature];
  feature.imageSrc = relativePathWithType;
  [self reloadFeature];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
