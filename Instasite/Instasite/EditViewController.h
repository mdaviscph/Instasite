//
//  EditViewController.h
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TemplateInput;
@class TemplateTabBarController;

@interface EditViewController : UIViewController 

// public properties so we can separate some of the EditViewController code into extensions
@property (nonatomic) NSInteger selectedFeature;
@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) TemplateInput *userInput;

- (void)reloadFeature;

@end
