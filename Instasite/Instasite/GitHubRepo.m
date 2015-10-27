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
#import <AFNetworking/AFNetworking.h>

@interface GitHubRepo ()

@property (strong, nonatomic) GitHubRepoApiWrapper *repoApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString *name;

@end

@implementation GitHubRepo

- (instancetype)initWithName:(NSString *)name accessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    _repoApiWrapper = [[GitHubRepoApiWrapper alloc] init];
    
    _manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    _manager.requestSerializer = requestSerializer;
    
    _name = name;
  }
  return self;
}

- (void)createWithComment:(NSString *)comment completion:(void(^)(NSError *))finalCompletion {
  
  RepoJsonRequest *repoRequest = [[RepoJsonRequest alloc] initWithName:self.name comment:comment];
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

@end
