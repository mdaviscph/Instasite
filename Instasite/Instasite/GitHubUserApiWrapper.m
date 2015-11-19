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
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>

@implementation GitHubUserApiWrapper

- (void)getUserUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, UserJsonResponse *))completion {
  
  NSString *url = @"https://api.github.com/user";
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    UserJsonResponse *userResponse = [[UserJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, userResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"GitHubUserApiWrapper:GitHubUserApiWrapper:getUserUsingManager status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    
    if (completion) {
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], nil);
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
    NSLog(@"GitHubUserApiWrapper:getRepos: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);

    if (completion) {
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], nil);
    }
  }];
}

// repackage AFNetworking error to include code from NSHTTPURLResponse and message, if any
- (NSError *)afErrorWithCode:(NSInteger)code description:(NSString *)description message:(NSString *)message {
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
  userInfo[NSLocalizedDescriptionKey] = description;
  userInfo[NSUnderlyingErrorKey] = message;
  return [[NSError alloc] initWithDomain:kErrorDomainAF code:code userInfo:userInfo];
}

@end
