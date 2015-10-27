//
//  GitHubUser.h
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubUser : NSObject

- (instancetype)initWithAccessToken:(NSString *)accessToken;

- (void)retrieveNameWithCompletion:(void(^)(NSError *, NSString *))finalCompletion;
- (void)retrieveReposWithBranch:(NSString *)branch completion:(void (^)(NSError *, NSArray *))finalCompletion;

@end
