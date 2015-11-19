//
//  GitHubUserApiWrapper.h
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class UserJsonResponse;
@class UserReposJsonRequest;
@class AFHTTPSessionManager;

@interface GitHubUserApiWrapper : NSObject

- (void)getUserUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, UserJsonResponse *))completion;
- (void)getRepos:(UserReposJsonRequest *)reposRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponseArray *))completion;

@end
