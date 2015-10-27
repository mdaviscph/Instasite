//
//  GitHubOAuthApiWrapper.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class OAuthJsonRequest;
@class OAuthJsonResponse;

@interface GitHubOAuthApiWrapper : NSObject

- (void)postOAuthRequest:(OAuthJsonRequest *)oauthRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, OAuthJsonResponse *))completion;

@end
