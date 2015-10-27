//
//  GitHubRepoApiWrapper.m
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubRepoApiWrapper.h"
#import "RepoJsonRequest.h"
#import "RepoJsonResponse.h"

@implementation GitHubRepoApiWrapper

- (void)createRepo:(RepoJsonRequest *)repoRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion {

  NSString *url = @"https://api.github.com/user/repos";
  
  [manager POST:url parameters:[repoRequest createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RepoJsonResponse *repoResponse = [[RepoJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, repoResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSLog(@"Error! GitHubRepoApiWrapper:createRepo: error: %@", error.localizedDescription);
    if (completion) {
      completion(error, nil);
    }
  }];
}

@end
