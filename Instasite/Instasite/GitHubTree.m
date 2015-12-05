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
#import "Constants.h"
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

- (void)makeAndCommitWithCompletion:(void(^)(NSError *, GitHubPagesStatus))finalCompletion {
  
  [self.dataApiWrapper postFileBlobsUsingManager:self.manager completion:^(NSError *error) {

    if (error && finalCompletion) {
      finalCompletion([self ourErrorWithCode:error.code description:@"Unable to publish to GitHub repository." message:@"Please retry the operation. One possible cause of this error is a corrupt image file."], GitHubPagesError);
    } else {
      [self postsWithCompletion:^(NSError *error, GitHubPagesStatus status) {
        if (finalCompletion) {
          finalCompletion(error, status);
        }
      }];
    }
  }];
}

- (void)postsWithCompletion:(void(^)(NSError *, GitHubPagesStatus status))finalCompletion {
  
  FileJsonRequestArray *filesForTree = [self.dataApiWrapper filesForTree];
  
  // note: if we are doing an update then self.committedTreeFiles is not nil
  TreeJsonRequest *treeRequest = [[TreeJsonRequest alloc] initWithFileList:filesForTree existingFileList:self.committedTreeFiles];
  [self.dataApiWrapper postTree:treeRequest usingManager:self.manager completion:^(NSError *error, TreeJsonResponse *treeResponse) {
    
    if (error && finalCompletion) {
      finalCompletion([self ourErrorWithCode:error.code description:@"Unable to publish to GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
    } else {

      // note: if we are doing an update then self.parentSha is not nil
      NSString *message = self.parentSha ? @"InstaSite update commit." : @"InstaSite initial commit.";
      CommitTreeJsonRequest *commitRequest = [[CommitTreeJsonRequest alloc] initWithTreeSha:treeResponse.sha message:message parentSha:self.parentSha];
      [self.dataApiWrapper postTreeCommit:commitRequest usingManager:self.manager completion:^(NSError *error, CommitTreeJsonResponse *commitResponse) {
        
        if (error && finalCompletion) {
          finalCompletion([self ourErrorWithCode:error.code description:@"Unable to publish to GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
        } else {
          
          NSString *ref = [NSString stringWithFormat:@"refs/heads/%@", self.branch];
          RefJsonRequest *refRequest = [[RefJsonRequest alloc] initWithRef:ref sha:commitResponse.sha];
          
          if (self.parentSha) {
            
            [self.dataApiWrapper patchTreeRef:refRequest usingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {

              if (error && finalCompletion) {
                finalCompletion([self ourErrorWithCode:error.code description:@"Unable to publish to GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
              } else {
                //NSLog(@"GitHubTree re-commit, refs complete.");
                if (finalCompletion) {
                  finalCompletion(nil, GitHubPagesInProgress);
                }
              }
            }];

          } else {
            
            [self.dataApiWrapper postTreeRef:refRequest usingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {

              if (error && finalCompletion) {
                finalCompletion([self ourErrorWithCode:error.code description:@"Unable to publish to GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
              } else {
                //NSLog(@"GitHubTree creation, commit, refs complete.");
                if (finalCompletion) {
                  finalCompletion(nil, GitHubPagesInProgress);
                }
              }
            }];
          }
        }
      }];
    }
  }];
}

- (void)updateAndCommitWithCompletion:(void(^)(NSError *, GitHubPagesStatus))finalCompletion {
  
  [self.dataApiWrapper getRefUsingManager:self.manager completion:^(NSError *error, RefJsonResponse *refResponse) {
    
    if (error && finalCompletion) {
      finalCompletion([self ourErrorWithCode:error.code description:@"Unable to access GitHub Pages." message:@"Please retry the operation."], GitHubPagesError);
    } else {
      
      [self.dataApiWrapper getTreeCommitWithRef:refResponse usingManager:self.manager completion:^(NSError *error, CommitTreeJsonResponse *commitTreeResponse) {
        
        if (error && finalCompletion) {
          finalCompletion([self ourErrorWithCode:error.code description:@"Unable to retrieve information from GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
        } else {
          
          self.parentSha = commitTreeResponse.sha;
          [self.dataApiWrapper getTreeWithCommit:commitTreeResponse usingManager:self.manager completion:^(NSError *error, TreeJsonResponse *treeResponse) {
            
            if (error && finalCompletion) {
              finalCompletion([self ourErrorWithCode:error.code description:@"Unable to retrieve information from GitHub repository." message:@"Please retry the operation."], GitHubPagesError);
            } else {
              
              self.committedTreeFiles = treeResponse.files;
              [self makeAndCommitWithCompletion:^(NSError *error, GitHubPagesStatus status) {
                if (finalCompletion) {
                  finalCompletion(error, status);
                }
              }];
            }
          }];
        }
      }];
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
