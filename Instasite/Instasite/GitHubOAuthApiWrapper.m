//
//  GitHubOAuthApiWrapper.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubOAuthApiWrapper.h"
#import "OAuthJsonRequest.h"
#import "OAuthJsonResponse.h"

@implementation GitHubOAuthApiWrapper

- (void)postOAuthRequest:(OAuthJsonRequest *)oauthRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, OAuthJsonResponse *))completion {
  
  NSString *url = @"https://github.com/login/oauth/access_token";
  
  [manager POST:url parameters:[oauthRequest createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    OAuthJsonResponse *oauthResponse = [[OAuthJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, oauthResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
    
    NSLog(@"Error! GitHubOAuthApiWrapper:postOAuthRequest: error: %@", error.localizedDescription);
    if (completion) {
      completion(error, nil);
    }
  }];
}

@end
