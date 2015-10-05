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

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *templateDirectory;
@property (strong, nonatomic) HtmlTemplate *templateCopy;
@property (strong, nonatomic) NSDictionary *templateMarkers;
@property (strong, nonatomic) NSMutableArray *images;

@property (strong, nonatomic) NSURL *indexHtmlURL;
@property (strong, nonatomic) NSURL *indexHtmlDirectoryURL;
@property (strong, nonatomic) NSURL *templateHtmlURL;
@property (strong, nonatomic) NSURL *userJsonURL;

@end
