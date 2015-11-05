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
#import "Repo.h"
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

- (void)retrieveReposWithCompletion:(void (^)(NSError *, NSArray *))finalCompletion {
  
  UserReposJsonRequest *userRequest = [[UserReposJsonRequest alloc] initWithType:@"owner"];
  [self.userApiWrapper getRepos:userRequest usingManager:self.manager completion:^(NSError *error, RepoJsonResponseArray *repoResponses) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubUser:retrieveReposWithCompletion:");
    }
    NSMutableArray *repos = [[NSMutableArray alloc] init];
    for (RepoJsonResponse *repoResponse in repoResponses) {
      Repo *repo = [[Repo alloc] initWithName:repoResponse.name description:repoResponse.aDescription owner:repoResponse.owner];
      [repos addObject:repo];
    }

    if (finalCompletion) {
      finalCompletion(error, repos);
    }
  }];
}

@end
