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
#import "PagesJsonResponse.h"
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubRepoApiWrapper ()

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *repoName;

@end

@implementation GitHubRepoApiWrapper

- (instancetype)initWithRepoName:(NSString *)repoName userName:(NSString *)userName {
  self = [super init];
  if (self) {
    _repoName = repoName;
    _userName = userName;
  }
  return self;
}

- (void)createRepo:(RepoJsonRequest *)repoRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion {

  NSString *url = @"https://api.github.com/user/repos";
  
  [manager POST:url parameters:[repoRequest createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RepoJsonResponse *repoResponse = [[RepoJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, repoResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"GitHubRepoApiWrapper:createRepo: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);

    if (completion) {
      RepoJsonResponse *repoResponse;
      if (taskResponse.statusCode == 422) {
        repoResponse = [[RepoJsonResponse alloc] initWithTest:GitHubRepoExists];    // attempt to create a repo that already exists
      } else {
        repoResponse = [[RepoJsonResponse alloc] initWithTest:GitHubRepoError];
      }
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], repoResponse);
    }
  }];
}

- (void)getRepoUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, RepoJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", self.userName, self.repoName];
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RepoJsonResponse *repoResponse = [[RepoJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, repoResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"GitHubRepoApiWrapper:getRepoUsingManager: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);

    if (completion) {
      RepoJsonResponse *repoResponse;
      if (taskResponse.statusCode == 404) {
        repoResponse = [[RepoJsonResponse alloc] initWithTest:GitHubRepoDoesNotExist];
      } else {
        repoResponse = [[RepoJsonResponse alloc] initWithTest:GitHubRepoError];
      }
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], repoResponse);
    }
  }];
}

- (void)getPagesStatusUsingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, PagesJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/pages", self.userName, self.repoName];

  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    PagesJsonResponse *pagesResponse = [[PagesJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, pagesResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"GitHubRepoApiWrapper:getPagesStatusUsingManager: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);

    if (completion) {
      PagesJsonResponse *pagesResponse;
      if (taskResponse.statusCode == 404) {
        pagesResponse = [[PagesJsonResponse alloc] initWithStatus:GitHubPagesNone];
      } else {
        pagesResponse = [[PagesJsonResponse alloc] initWithStatus:GitHubPagesError];
      }
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], pagesResponse);
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
