//
//  GitHubRepoApiWrapper.h
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "TypeDefsEnums.h"

@class UserReposJsonRequest;
@class RepoJsonRequest;
@class RepoJsonResponse;

@interface GitHubRepoApiWrapper : NSObject

- (void)createRepo:(RepoJsonRequest *)repoRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion;

@end
