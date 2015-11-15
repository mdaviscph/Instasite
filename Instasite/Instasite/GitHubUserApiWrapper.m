//
//  GitHubUserApiWrapper.m
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubUserApiWrapper.h"
#import "UserJsonResponse.h"
#import "RepoJsonResponse.h"
#import "UserReposJsonRequest.h"

@implementation GitHubUserApiWrapper

- (void)getUserUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, UserJsonResponse *))completion {
  
  NSString *url = @"https://api.github.com/user";
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    UserJsonResponse *userResponse = [[UserJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, userResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSLog(@"Error! GitHubUserApiWrapper:getUserUsingManager: error: %@", error.localizedDescription);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getRepos:(UserReposJsonRequest *)reposRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponseArray *))completion {
  
  NSString *url = @"https://api.github.com/user/repos";
  
  [manager GET:url parameters:[reposRequest createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RepoJsonResponseMutableArray *repoResponses = [[NSMutableArray alloc] init];
    for (NSDictionary *repoDict in responseObject) {
      RepoJsonResponse *repoResponse = [[RepoJsonResponse alloc] initFromJson:repoDict];
      [repoResponses addObject:repoResponse];
    }
    
    if (completion) {
      completion(nil, repoResponses);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubUserApiWrapper:getRepos: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}
  
@end
