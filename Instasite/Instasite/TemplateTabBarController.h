//
//  TemplateTabBarController.h
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeDefsEnums.h"

@class HtmlTemplate;
@class UserInput;

@interface TemplateTabBarController : UITabBarController

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *templateDirectory;

@property (strong, nonatomic) NSString *repoName;
@property (nonatomic) GitHubRepoTest repoExists;
@property (nonatomic) GitHubPagesStatus pagesStatus;

@property (strong, nonatomic) UserInput *userInput;
@property (strong, nonatomic) ImagesDictionary *images;

- (NSURL *)htmlFileURL:(NSString *)fileName;
- (NSURL *)indexDirectoryURL;
- (NSURL *)jsonFileURL:(NSString *)fileName;
   
@end
