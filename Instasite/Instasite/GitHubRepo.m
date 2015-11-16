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
#import "Repo.h"
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

- (void)createWithComment:(NSString *)comment completion:(void(^)(NSError *))finalCompletion {
  
  RepoJsonRequest *repoRequest = [[RepoJsonRequest alloc] initWithName:self.repoName comment:comment];
  [self.repoApiWrapper createRepo:repoRequest usingManager:self.manager completion:^(NSError *error, RepoJsonResponse *repoResponse) {

    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubRepo:createWithComment:");
    }
    if (finalCompletion) {
      finalCompletion(error);
    }
  }];
}

- (void)retrieveWithCompletion:(void(^)(NSError *, Repo *))finalCompletion {
  
  [self.repoApiWrapper getRepoUsingManager:self.manager completion:^(NSError *error, RepoJsonResponse *repoResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubRepo:retrieveWithCompletion:");
    }
    Repo *repo = [[Repo alloc] initWithName:repoResponse.name description:repoResponse.aDescription owner:repoResponse.owner updatedAt:repoResponse.updatedAt];
    if (finalCompletion) {
      finalCompletion(error, repo);
    }
  }];
}

- (void)retrievePagesStatusWithCompletion:(void(^)(NSError *, GitHubPagesStatus))finalCompletion {
  
  [self.repoApiWrapper getPagesStatusUsingManager:self.manager completion:^(NSError *error, PagesJsonResponse *pagesResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubRepo:retrievePagesStatusWithCompletion:");
    }
    if (finalCompletion) {
      finalCompletion(error, pagesResponse.status);
    }
  }];
}

@end
