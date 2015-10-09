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

@interface GitHubService : NSObject

+ (instancetype)sharedInstance;

+ (void)saveTokenInURLtoKeychain:(NSURL *)url;

- (UserInfo *)getUserInfo:(void(^)(NSError *error, UserInfo *user))completion;
- (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion;
- (void)getRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
- (void)getRefs:(NSString *)repoName completion:(void(^)(NSError *, CommitJson *))completion;
- (void)getPages:(NSString *)repoName completion:(void(^)(NSError *))completion;

- (void)createRepo:(NSString *)repoName description:(NSString *)description completion:(void(^)(NSError *))completion;
- (void)createBranchForRepo:(NSString *)repoName parentSHA:(NSString *)sha completion:(void(^)(NSError *))completion;

- (void)pushIndexHtmlFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
- (void)pushJsonFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;

- (void)pushImageFiles:(NSMutableArray *)imageFiles forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
- (void)pushSupportingFiles:(NSMutableArray *)cssFiles forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;

@end
