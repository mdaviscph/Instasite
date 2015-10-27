//
//  GitHubTree.m
//  Instasite
//
//  Created by mike davis on 10/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubTree.h"
#import "GitHubDataApiWrapper.h"
#import "TreeJsonRequest.h"
#import "TreeJsonResponse.h"
#import "CommitTreeJsonRequest.h"
#import "CommitTreeJsonResponse.h"
#import "RefJsonRequest.h"
#import "RefJsonResponse.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubTree ()

@property (strong, nonatomic) GitHubDataApiWrapper *dataApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString *branch;

@end

@implementation GitHubTree

- (instancetype)initWithFiles:(FileInfoArray *)files userName:(NSString *)userName repoName:(NSString *)repoName branch:(NSString *)branch accessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    _dataApiWrapper = [[GitHubDataApiWrapper alloc] initWithFiles:files userName:userName repoName:repoName];
    
    _manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    _manager.requestSerializer = requestSerializer;
    
    _branch = branch;
  }
  return self;
}

- (void)createAndCommitWithCompletion:(void(^)(NSError *))finalCompletion {
  
  [self.dataApiWrapper postFileBlobsUsingManager:self.manager completion:^(NSError *error) {

    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubTree:createAndCommitWithCompletion: postFileBlobsUsingManager");
      if (finalCompletion) {
        finalCompletion(error);
      }
    } else {
      [self postsWithCompletion:^(NSError *error) {
        if (finalCompletion) {
          finalCompletion(error);
        }
      }];
    }
  }];
}

- (void)postsWithCompletion:(void(^)(NSError *))finalCompletion {
  
  FileJsonRequestArray *filesForTree = [self.dataApiWrapper filesForTree];
  TreeJsonRequest *treeRequest = [[TreeJsonRequest alloc] initWithFileList:filesForTree];
  [self.dataApiWrapper postTree:treeRequest usingManager:self.manager completion:^(NSError *error, TreeJsonResponse *treeResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubTree:postsWithCompletion: postTree");
      if (finalCompletion) {
        finalCompletion(error);
      }
    } else {

      CommitTreeJsonRequest *commitRequest = [[CommitTreeJsonRequest alloc] initWithSha:treeResponse.sha message:@"InstaSite commit"];
      [self.dataApiWrapper postTreeCommit:commitRequest usingManager:self.manager completion:^(NSError *error, CommitTreeJsonResponse *commitResponse) {
        
        // TODO - alert popover?
        if (error) {
          NSLog(@"Error! GitHubTree:createAndCommitTreeWithCompletion: postTreeCommit");
          if (finalCompletion) {
            finalCompletion(error);
          }
        } else {
          
          NSString *ref = [NSString stringWithFormat:@"refs/heads/%@", self.branch];
          RefJsonRequest *refRequest = [[RefJsonRequest alloc] initWithRef:ref sha:commitResponse.sha];
          [self.dataApiWrapper postTreeRef:refRequest usingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {

            // TODO - alert popover?
            if (error) {
              NSLog(@"Error! GitHubTree:createAndCommitTreeWithCompletion: postTreeRef");
              if (finalCompletion) {
                finalCompletion(error);
              }
            } else {
              //NSLog(@"GitHubTree creation, commit, refs complete.");
              if (finalCompletion) {
                // TODO - figure out a way to
                finalCompletion(nil);
              }
            }
          }];
        }
      }];
    }
  }];
}

@end
