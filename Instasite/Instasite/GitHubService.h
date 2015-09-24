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
+ (void)pushFilesToGithub:(NSString *)repoName username:(NSString *)username templateName:(NSString *)templateName completionHandler:(void(^) (NSError *))completionHandler;
+ (void)getUsernameAndEmailFromGithub:(void (^) (NSError *error, NSString *username))completionHandler;
+ (void)pushImagesToGithub:(NSString *)imageName imagePath:(NSString *)imagePath forUser:(NSString *)username forRepo:(NSString *)repoName;
+ (void)pushJSONToGithub:(NSString *)jsonPath forUser:(NSString *)username forRepo:(NSString *)repoName;
@end
