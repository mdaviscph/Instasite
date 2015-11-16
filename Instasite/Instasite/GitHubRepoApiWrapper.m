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
    
    NSLog(@"Error! GitHubRepoApiWrapper:createRepo: error: %@", error.localizedDescription);
    if (completion) {
      completion(error, nil);
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
    NSLog(@"Error! GitHubRepoApiWrapper:getRepoUsingManager: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
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
    NSLog(@"Error! GitHubRepoApiWrapper:getPagesStatusUsingManager: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}


@end
