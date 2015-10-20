//
//  GitHubService.h
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileInfo;
@class UserInfo;
@class CommitJson;
@class FileJson;

@interface GitHubService : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isAuthorized;

+ (void)saveTokenInURLtoKeychain:(NSURL *)url;

- (UserInfo *)getUserInfo:(void(^)(NSError *error, UserInfo *user))completion;
- (NSString *)ghPagesUrl;

- (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion;
- (void)getRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
- (void)getRefs:(NSString *)repoName completion:(void(^)(NSError *, CommitJson *))completion;
- (void)getPages:(NSString *)repoName completion:(void(^)(NSError *))completion;

- (void)getFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *, FileJson *))completion;

- (void)createRepo:(NSString *)repoName description:(NSString *)description completion:(void(^)(NSError *))completion;
- (void)createBranchForRepo:(NSString *)repoName parentSHA:(NSString *)sha completion:(void(^)(NSError *))completion;

- (void)pushIndexHtmlFile:(FileInfo *)file forRepo:(NSString *)repoName withSha:(NSString *)sha completion:(void(^)(NSError *))completion;
- (void)pushJsonFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;

- (void)pushFiles:(NSArray *)files forRepo:(NSString *)repoName completion:(void(^)(NSError *, NSArray *))completion;

@end
