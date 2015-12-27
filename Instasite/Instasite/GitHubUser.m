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
#import "Constants.h"
#import "TypeDefsEnums.h"
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
    
    NSError *ourError;
    if (error) {
      if (error.code == 401) {
        ourError = [self ourErrorWithCode:error.code description:@"You must have a GitHub account and be logged in to proceed." message:@"You will be prompted to create an account (Sign In) if necessary or to Log In when you retry the operation."];
      } else {
        ourError = [self ourErrorWithCode:error.code description:@"Unable to retrieve GitHub user name." message:@"Please retry the operation."];
      }
    }
    
    if (finalCompletion) {
      finalCompletion(ourError, userResponse.name);
    }
  }];
}

- (void)retrieveReposWithCompletion:(void (^)(NSError *, NSArray *))finalCompletion {
  
  UserReposJsonRequest *userRequest = [[UserReposJsonRequest alloc] initWithType:@"owner"];
  [self.userApiWrapper getRepos:userRequest usingManager:self.manager completion:^(NSError *error, RepoJsonResponseArray *repoResponses) {
    
    NSError *ourError;
    if (error) {
      if (error.code == 404) {
        ourError = nil;                 // no repos is not an error, it just means the user is brand new to GitHub
      } else {
        ourError = [self ourErrorWithCode:error.code description:@"You must have a GitHub account and be logged in to proceed." message:@"You will be prompted to create an account (Sign In) if necessary or to Log In."];
      }
    }

    NSMutableArray *repos = [[NSMutableArray alloc] init];
    for (RepoJsonResponse *repoResponse in repoResponses) {
      Repo *repo = [[Repo alloc] initWithName:repoResponse.name description:repoResponse.aDescription owner:repoResponse.owner updatedAt:repoResponse.updatedAt];
      [repos addObject:repo];
    }

    if (finalCompletion) {
      finalCompletion(ourError, repos);
    }
  }];
}

// repackage error to include project specific code and retry suggestion, if any
- (NSError *)ourErrorWithCode:(NSInteger)code description:(NSString *)description message:(NSString *)message {
  NSInteger ourCode;
  switch (code) {
    case 401:
      ourCode = ErrorCodeNotAuthorized;
      break;
    case 404:
      ourCode = ErrorCodeEntityNotFound;
      break;
    case 422:
      ourCode = ErrorCodeOperationIncomplete;
      break;
    default:
      ourCode = ErrorCodeUnknownError;
      break;
  }
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
  userInfo[NSLocalizedDescriptionKey] = description;
  userInfo[NSLocalizedRecoverySuggestionErrorKey] = message;
  return [[NSError alloc] initWithDomain:kErrorDomain code:ourCode userInfo:userInfo];
}

@end
