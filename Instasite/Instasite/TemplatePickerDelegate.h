//
//  TemplatePickerDelegate.h
//  Instasite
//
//  Created by mike davis on 11/10/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TemplatePickerViewController;

@protocol TemplatePickerDelegate <NSObject>

- (void)templatePicker:(TemplatePickerViewController *)picker didFinishPickingWithName:(NSString *)name;
- (void)templatePickerDidCancel:(TemplatePickerViewController *)picker;

@end

