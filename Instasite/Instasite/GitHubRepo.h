//
//  GitHubRepo.h
//  Instasite
//
//  Created by mike davis on 10/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubRepo : NSObject

- (instancetype)initWithName:(NSString *)name accessToken:(NSString *)accessToken;

- (void)createWithComment:(NSString *)comment completion:(void(^)(NSError *))finalCompletion;

@end
