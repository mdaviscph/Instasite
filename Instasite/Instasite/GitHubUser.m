//
//  GitHubUser.m
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubUser.h"
#import "GitHubUserApiWrapper.h"
#import "UserJsonResponse.h"
#import "UserReposJsonRequest.h"
#import "RepoJsonResponse.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubUser ()

@property (strong, nonatomic) GitHubUserApiWrapper *userApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation GitHubUser

- (instancetype)initWithAccessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    _userApiWrapper = [[GitHubUserApiWrapper alloc] init];
    
    _manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    _manager.requestSerializer = requestSerializer;
  }
  return self;
}

- (void)retrieveNameWithCompletion:(void (^)(NSError *, NSString *))finalCompletion {
  
  [self.userApiWrapper getUserUsingManager:self.manager completion:^(NSError *error, UserJsonResponse *userResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubUser:retrieveNameWithCompletion:");
    }
    if (finalCompletion) {
      finalCompletion(error, userResponse.name);
    }
  }];
}

- (void)retrieveReposWithBranch:(NSString *)branch completion:(void (^)(NSError *, NSArray *))finalCompletion {
  
  UserReposJsonRequest *userRequest = [[UserReposJsonRequest alloc] initWithType:@"owner"];
  [self.userApiWrapper getRepos:userRequest usingManager:self.manager completion:^(NSError *error, RepoJsonResponseArray *repoResponses) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubUser:retrieveReposWithBranch:");
    }
    NSMutableArray *repoNames = [[NSMutableArray alloc] init];
    for (RepoJsonResponse *repo in repoResponses) {
      if (branch && [repo.defaultBranch isEqualToString:branch]) {
        [repoNames addObject:repo.name];
      } else {
        [repoNames addObject:repo.name];
      }
    }

    if (finalCompletion) {
      finalCompletion(error, repoNames);
    }
  }];
}

@end
