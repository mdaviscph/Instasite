//
//  GitHubRepoApiWrapper.h
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class RepoJsonRequest;
@class RepoJsonResponse;
@class PagesJsonResponse;
@class AFHTTPSessionManager;

@interface GitHubRepoApiWrapper : NSObject

- (instancetype)initWithRepoName:(NSString *)repoName userName:(NSString *)userName;

- (void)createRepo:(RepoJsonRequest *)repoRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion;
- (void)getRepoUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion;
- (void)getPagesStatusUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, PagesJsonResponse *))completion;


@end
