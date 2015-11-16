//
//  GitHubDataApiWrapper.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubDataApiWrapper.h"
#import "FileInfo.h"
#import "FileJsonRequest.h"
#import "BlobJsonRequest.h"
#import "BlobJsonResponse.h"
#import "TreeJsonRequest.h"
#import "TreeJsonResponse.h"
#import "CommitTreeJsonRequest.h"
#import "CommitTreeJsonResponse.h"
#import "RefJsonRequest.h"
#import "RefJsonResponse.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubDataApiWrapper ()

@property (strong, nonatomic) FileInfoArray *files;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *repoName;
@property (strong, nonatomic) NSString *branch;

@property (strong, nonatomic) FileJsonRequestMutableArray *fileJsonList;

@end

@implementation GitHubDataApiWrapper

- (FileJsonRequestMutableArray *)fileJsonList {
  if (!_fileJsonList) {
    _fileJsonList = [[FileJsonRequestMutableArray alloc] init];
  }
  return _fileJsonList;
}

- (instancetype)initWithFiles:(FileInfoArray *)files userName:(NSString *)userName repoName:(NSString *)repoName branch:(NSString *)branch {
  self = [super init];
  if (self) {
    _files = files;
    _userName = userName;
    _repoName = repoName;
    _branch = branch;
  }
  return self;
}

// make non-mutable access available
- (FileJsonRequestArray *)filesForTree {
  return [[FileJsonRequestArray alloc] initWithArray:self.fileJsonList];
}

// note that for update GitHub seems to compare image files and returns same sha if file is the same
- (void)postFileBlobsUsingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *))completion {

  // need a dispatch group for notification of all of the file blobs being posted
  dispatch_group_t postBlobs = dispatch_group_create();

  for (FileInfo *file in self.files) {
    
    dispatch_group_enter(postBlobs);
    BlobJsonRequest *blob = [[BlobJsonRequest alloc] initWithFileInfo:file];
    [self postBlob:blob usingManager:manager completion:^(NSError *error, BlobJsonResponse *blobResponse) {
 
      dispatch_group_leave(postBlobs);
      //NSLog(@"POST file(blob) %@ sha: %@", file, blobResponse.sha);

      if (error) {
        NSLog(@"Error! GitHubDataApiWrapper:postFileBlobsUsingManager: file: %@ error: %@", file, error.localizedDescription);
      } else {
        
        FileJsonRequest *fileJson = [[FileJsonRequest alloc] initWithPath:[file filepathFromRemoteDirectory] sha:blobResponse.sha];
        [self.fileJsonList addObject:fileJson];
      }
    }];
  }
  
  dispatch_group_notify(postBlobs, dispatch_get_main_queue(), ^ {
    if (completion) {
      completion(nil);
    }
  });
}

- (void)postBlob:(BlobJsonRequest *)blob usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, BlobJsonResponse *))completion {

  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/blobs", self.userName, self.repoName];
  
  [manager POST:url parameters:[blob createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    BlobJsonResponse *blobResponse = [[BlobJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, blobResponse);
    }

  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:postBlob: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)postTree:(TreeJsonRequest *)tree usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, TreeJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/trees", self.userName, self.repoName];
  
  [manager POST:url parameters:[tree createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    TreeJsonResponse *treeResponse = [[TreeJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, treeResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:postTree: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)postTreeCommit:(CommitTreeJsonRequest *)commit usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, CommitTreeJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/commits", self.userName, self.repoName];
  
  [manager POST:url parameters:[commit createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    CommitTreeJsonResponse *commitTreeResponse = [[CommitTreeJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, commitTreeResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:postTreeCommit: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)postTreeRef:(RefJsonRequest *)ref usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, RefJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs", self.userName, self.repoName];
  
  [manager POST:url parameters:[ref createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RefJsonResponse *refResponse = [[RefJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, refResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:postTreeRef: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)patchTreeRef:(RefJsonRequest *)ref usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, RefJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs/heads/%@", self.userName, self.repoName, self.branch];
  
  [manager PATCH:url parameters:[ref createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

    RefJsonResponse *refResponse = [[RefJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, refResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:patchTreeRef: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getRefUsingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, RefJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs/heads/%@", self.userName, self.repoName, self.branch];
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    RefJsonResponse *refResponse = [[RefJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, refResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:getRef: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getTreeCommitWithRef:(RefJsonResponse *)refResponse usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, CommitTreeJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/commits/%@", self.userName, self.repoName, refResponse.objectSha];
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    CommitTreeJsonResponse *commitTreeResponse = [[CommitTreeJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, commitTreeResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:getTreeCommitWithRef: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getTreeWithCommit:(CommitTreeJsonResponse *)commitTreeResponse usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, TreeJsonResponse *))completion {

  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/trees/%@", self.userName, self.repoName, commitTreeResponse.sha];
  
  [manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    TreeJsonResponse *treeResponse = [[TreeJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, treeResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:getTreeWithCommit: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getTreeRecursivelyWithCommit:(CommitTreeJsonResponse *)commitTreeResponse usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, TreeJsonResponse *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/trees/%@", self.userName, self.repoName, commitTreeResponse.sha];
  
  NSDictionary *parameters = @{@"recursive" : @(1)};
  [manager GET:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    TreeJsonResponse *treeResponse = [[TreeJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, treeResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"Error! GitHubDataApiWrapper:getTreeRecursivelyWithCommit: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);
    if (completion) {
      completion(error, nil);
    }
  }];
}

@end
