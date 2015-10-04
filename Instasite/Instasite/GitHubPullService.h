//
//  GitHubPullService.h
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubPullService : NSObject

+ (void)getJSONFromGithub:(NSString *)repoName email:(NSString *)email completion:(void (^)(NSError *))completion;

@end
