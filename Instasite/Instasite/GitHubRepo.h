//
//  GitHubRepo.h
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class Repo;

@interface GitHubRepo : NSObject

- (instancetype)initWithName:(NSString *)repoName userName:(NSString *)userName accessToken:(NSString *)accessToken;

- (void)createWithComment:(NSString *)comment completion:(void(^)(NSError *))finalCompletion;
- (void)retrieveWithCompletion:(void(^)(NSError *, Repo *))finalCompletion;
- (void)retrievePagesStatusWithCompletion:(void(^)(NSError *, GitHubPagesStatus))finalCompletion;

@end
