//
//  GitHubAccessToken.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GitHubAccessToken : NSObject

- (instancetype)initWithCode:(NSString *)code clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (void)retrieveTokenWithCompletion:(void(^)(NSError *error, NSString *token))finalCompletion;

@end
