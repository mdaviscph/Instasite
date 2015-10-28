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

@property (strong, nonatomic) NSString *repoName;

@property (strong, nonatomic) HtmlTemplate *templateCopy;
@property (strong, nonatomic) NSDictionary *templateMarkers;
@property (strong, nonatomic) NSMutableDictionary *images;

@property (strong, readonly, nonatomic) NSURL *indexHtmlURL;
@property (strong, readonly, nonatomic) NSURL *indexHtmlDirectoryURL;
@property (strong, readonly, nonatomic) NSURL *templateHtmlURL;
@property (strong, readonly, nonatomic) NSURL *userJsonURL;

@property (strong, readonly, nonatomic) NSString *accessToken;      // retrieved from Keychain
@property (strong, readonly, nonatomic) NSString *userName;         // retrieved from UserDefaults

@end
