//
//  HtmlTemplate.h
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class UserInput;

@interface HtmlTemplate : NSObject

@property (strong, readonly, nonatomic) NSString *html;

- (instancetype)initWithURL:(NSURL *)htmlURL;

- (BOOL)writeToURL:(NSURL *)htmlURL withInputGroups:(InputGroupDictionary *)groups;

- (BOOL)addInputGroupsToUserInput:(UserInput *)userInput;

@end
