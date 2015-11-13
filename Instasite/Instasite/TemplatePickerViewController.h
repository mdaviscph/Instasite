//
//  TemplatePickerViewController.h
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplatePickerDelegate.h"

@interface TemplatePickerViewController : UIViewController

@property (weak, nonatomic) id<TemplatePickerDelegate> delegate;

@end
