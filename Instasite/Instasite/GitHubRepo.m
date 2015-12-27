//
//  GitHubRepo.m
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubRepo.h"
#import "GitHubRepoApiWrapper.h"
#import "RepoJsonRequest.h"
#import "RepoJsonResponse.h"
#import "PagesJsonResponse.h"
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubRepo ()

@property (strong, nonatomic) GitHubRepoApiWrapper *repoApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString *repoName;
@property (strong, nonatomic) NSString *userName;

@end

@implementation GitHubRepo

- (instancetype)initWithName:(NSString *)repoName userName:(NSString *)userName accessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    _repoApiWrapper = [[GitHubRepoApiWrapper alloc] initWithRepoName:repoName userName:userName];
    
    _manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    _manager.requestSerializer = requestSerializer;
    
    _repoName = repoName;
    _userName = userName;
  }
  return self;
}

- (void)createWithComment:(NSString *)comment completion:(void(^)(NSError *, GitHubRepoTest))finalCompletion {
  
  RepoJsonRequest *repoRequest = [[RepoJsonRequest alloc] initWithName:self.repoName comment:comment];
  [self.repoApiWrapper createRepo:repoRequest usingManager:self.manager completion:^(NSError *error, RepoJsonResponse *repoResponse) {

    NSError *ourError;
    if (error) {
      if (error.code == 422) {
        ourError = [self ourErrorWithCode:error.code description:@"This GitHub repository already exists." message:@"To publish to an existing repository, you must explicitly choose that repository. Or you can rename this Web Page repository to a new name."];
      } else {
        ourError = [self ourErrorWithCode:error.code description:@"Unable to create GitHub repository." message:@"Please retry the operation."];
      }
    }
    if (finalCompletion) {
      finalCompletion(ourError, repoResponse.exists);
    }
  }];
}

- (void)retrieveExistenceWithCompletion:(void(^)(NSError *, GitHubRepoTest))finalCompletion {
  
  [self.repoApiWrapper getRepoUsingManager:self.manager completion:^(NSError *error, RepoJsonResponse *repoResponse) {
    
    NSError *ourError;
    if (error && error.code != 404) {
      ourError = [self ourErrorWithCode:error.code description:@"Unable to determine existence of GitHub repository." message:@"Please retry the operation."];
    }
    if (finalCompletion) {
      finalCompletion(ourError, repoResponse.exists);
    }
  }];
}

- (void)retrievePagesStatusWithCompletion:(void(^)(NSError *, GitHubPagesStatus))finalCompletion {
  
  [self.repoApiWrapper getPagesStatusUsingManager:self.manager completion:^(NSError *error, PagesJsonResponse *pagesResponse) {
    
    NSError *ourError;
    if (error && error.code != 404) {
      ourError = [self ourErrorWithCode:error.code description:@"Unable to determine status of GitHub Pages build." message:@"Please retry the operation."];
    }
    if (finalCompletion) {
      finalCompletion(ourError, pagesResponse.status);
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
