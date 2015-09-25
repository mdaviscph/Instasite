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
+ (void)serviceForRepoNameInput:(NSString *)repoNameInput descriptionInput:(NSString *)descriptionInput completionHandler:(void (^) (NSError *))completionHandler;
+ (void)pushFilesToGithub:(NSString *)repoName indexHtmlFile:(NSString *)indexHtmlFile email:(NSString *)userEmail completionHandler:(void(^) (NSError *))completionHandler;

+ (void)getUsernameFromGithub:(void (^) (NSError *error, NSString *username))completionHandler;
+ (void)pushImagesToGithub:(NSString *)imageName imagePath:(NSString *)imagePath email:(NSString *)userEmail forRepo:(NSString *)repoName;
+ (void)pushCSSToGithub:(NSString *)fileName cssPath:(NSString *)cssPath finalPath:(NSString *)localPath email:(NSString *)userEmail forRepo:(NSString *)repoName;
+ (void)pushJSONToGithub:(NSString *)jsonPath email:(NSString *)userEmail forRepo:(NSString *)repoName;


@end
