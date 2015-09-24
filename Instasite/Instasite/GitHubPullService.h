//
//  GitHubPullService.h
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubPullService : NSObject

+ (void)getJSONFromGithub:(NSString *)repoName username:(NSString *)username email:(NSString *)email templateName:(NSString *)templateName completionHandler:(void(^) (NSError *))completionHandler;

@end
