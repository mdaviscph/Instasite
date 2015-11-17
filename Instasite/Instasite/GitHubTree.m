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
#import "FileJsonResponse.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubTree ()

@property (strong, nonatomic) GitHubDataApiWrapper *dataApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@property (strong, nonatomic) NSString *branch;
@property (strong, nonatomic) NSString *parentSha;                        // used if updating branch, nil if creating branch (tree)
@property (strong, nonatomic) FileJsonResponseArray *committedTreeFiles;  // used if updating branch, nil if creating branch (tree)

@end

@implementation GitHubTree

- (instancetype)initWithFiles:(FileInfoArray *)files userName:(NSString *)userName repoName:(NSString *)repoName branch:(NSString *)branch accessToken:(NSString *)accessToken {
  self = [super init];
  if (self) {
    _dataApiWrapper = [[GitHubDataApiWrapper alloc] initWithFiles:files userName:userName repoName:repoName branch:branch];
    
    _manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    _manager.requestSerializer = requestSerializer;
    
    _branch = branch;
  }
  return self;
}

- (void)makeAndCommitWithCompletion:(void(^)(NSError *))finalCompletion {
  
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
  
  // note: if we are doing an update then self.committedTreeFiles is not nil
  TreeJsonRequest *treeRequest = [[TreeJsonRequest alloc] initWithFileList:filesForTree existingFileList:self.committedTreeFiles];
  [self.dataApiWrapper postTree:treeRequest usingManager:self.manager completion:^(NSError *error, TreeJsonResponse *treeResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubTree:postsWithCompletion: postTree");
      if (finalCompletion) {
        finalCompletion(error);
      }
    } else {

      // note: if we are doing an update then self.parentSha is not nil
      NSString *message = self.parentSha ? @"InstaSite update commit." : @"InstaSite initial commit.";
      CommitTreeJsonRequest *commitRequest = [[CommitTreeJsonRequest alloc] initWithTreeSha:treeResponse.sha message:message parentSha:self.parentSha];
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
          
          if (self.parentSha) {
            
            [self.dataApiWrapper patchTreeRef:refRequest usingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {
              
              // TODO - alert popover?
              if (error) {
                NSLog(@"Error! GitHubTree:createAndCommitTreeWithCompletion: patchTreeRef");
                if (finalCompletion) {
                  finalCompletion(error);
                }
              } else {
                //NSLog(@"GitHubTree creation, commit, refs complete.");
                if (finalCompletion) {
                  finalCompletion(nil);
                }
              }
            }];

          } else {
            
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
                  finalCompletion(nil);
                }
              }
            }];
          }
        }
      }];
    }
  }];
}

- (void)updateAndCommitWithCompletion:(void(^)(NSError *))finalCompletion {
  
  [self.dataApiWrapper getRefUsingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {
    
    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! getRefUsingManager:");
      if (finalCompletion) {
        finalCompletion(error);
      }
    } else {
      
      [self.dataApiWrapper getTreeCommitWithRef:refResponse usingManager:self.manager completion:^(NSError *error, CommitTreeJsonResponse *commitTreeResponse) {
        
        // TODO - alert popover?
        if (error) {
          NSLog(@"Error! getTreeCommitWithRef:");
          if (finalCompletion) {
            finalCompletion(error);
          }
        } else {
          
          self.parentSha = commitTreeResponse.sha;
          [self.dataApiWrapper getTreeRecursivelyWithCommit:commitTreeResponse usingManager:self.manager completion:^(NSError *error, TreeJsonResponse *treeResponse) {
            
            // TODO - alert popover?
            if (error) {
              NSLog(@"Error! getTreeCommitWithRef:");
              if (finalCompletion) {
                finalCompletion(error);
              }
            } else {
              
              self.committedTreeFiles = treeResponse.files;
              [self makeAndCommitWithCompletion:^(NSError *error) {
                if (finalCompletion) {
                  finalCompletion(error);
                }
              }];
            }
          }];
        }
      }];
    }
  }];
}

@end
