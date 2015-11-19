//
//  RepoJsonResponse.h
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface RepoJsonResponse : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *aDescription;
@property (strong, nonatomic) NSString *defaultBranch;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSDate *updatedAt;

@property (nonatomic) GitHubRepoTest exists;

- (instancetype)initFromJson:(NSDictionary *)json;
- (instancetype)initWithTest:(GitHubRepoTest)exists;

@end
