//
//  GitHubService.h
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubService : NSObject

+ (void)exchangeCodeInURL:(NSURL *)url;

+ (void)createRepo:(NSString *)repoName description:(NSString *)description completion:(void(^)(NSError *))completion;

+ (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion;
+ (void)getUsernameFromGithub:(void(^)(NSError *error, NSString *username))completion;

+ (void)pushFilesToGithub:(NSString *)repoName indexHtmlFile:(NSString *)indexHtmlFile user:(NSString *)userName email:(NSString *)userEmail completion:(void(^)(NSError *))completion;
+ (void)pushImagesToGithub:(NSString *)imageName imagePath:(NSString *)imagePath user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
+ (void)pushCSSToGithub:(NSMutableArray *)cssFiles user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;
+ (void)pushJSONToGithub:(NSString *)jsonPath user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion;

@end
