//
//  PagesJsonResponse.h
//  Instasite
//
//  Created by mike davis on 11/16/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypeDefsEnums.h"

@interface PagesJsonResponse : UILabel

@property (nonatomic) GitHubPagesStatus status;

- (instancetype)initFromJson:(NSDictionary *)json;
- (instancetype)initWithStatus:(GitHubPagesStatus)status;

@end
