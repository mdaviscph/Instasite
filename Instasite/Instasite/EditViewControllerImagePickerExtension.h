//
//  EditViewControllerImagePickerExtension.h
//  Instasite
//
//  Created by mike davis on 9/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewController.h"
#import <UIKit/UIKit.h>

@interface EditViewController (ImagePickerExtension) <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)actionSheetForImageSelection:(UIButton *)button;

@end
