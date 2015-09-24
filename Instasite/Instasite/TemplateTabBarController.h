//
//  TemplateTabBarController.h
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HtmlTemplate;

@interface TemplateTabBarController : UITabBarController

@property (strong, nonatomic) NSString *templateDirectory;
@property (strong, nonatomic) NSString *workingFilename;
@property (strong, nonatomic) HtmlTemplate *workingHtml;

@end
