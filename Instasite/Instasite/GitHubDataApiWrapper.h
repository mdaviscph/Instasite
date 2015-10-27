//
//  GitHubDataApiWrapper.h
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"
#import <AFNetworking/AFNetworking.h>

@class TreeJsonRequest;
@class TreeJsonResponse;
@class CommitTreeJsonRequest;
@class CommitTreeJsonResponse;
@class RefJsonRequest;
@class RefJsonResponse;

@interface GitHubDataApiWrapper : NSObject

- (instancetype)initWithFiles:(FileInfoArray *)files userName:(NSString *)userName repoName:(NSString *)repoName;

- (void)postFileBlobsUsingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *))completion;
- (void)postTree:(TreeJsonRequest *)tree usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, TreeJsonResponse *))completion;
- (void)postTreeCommit:(CommitTreeJsonRequest *)commit usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, CommitTreeJsonResponse *))completion;
- (void)postTreeRef:(RefJsonRequest *)ref usingManager:(AFHTTPSessionManager *)manager completion:(void(^)(NSError *, RefJsonResponse *))completion;

- (void)getRef:(RefJsonRequest *)refRequest usingManager:(AFHTTPSessionManager *)manager  completion:(void(^)(NSError *, RefJsonResponse *))completion;

- (FileJsonRequestArray *)filesForTree;

@end
