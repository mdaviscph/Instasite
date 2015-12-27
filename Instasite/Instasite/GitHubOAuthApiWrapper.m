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
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>

@implementation GitHubOAuthApiWrapper

- (void)postOAuthRequest:(OAuthJsonRequest *)oauthRequest usingManager:(AFHTTPSessionManager *)manager completion:(void (^)(NSError *, OAuthJsonResponse *))completion {
  
  NSString *url = @"https://github.com/login/oauth/access_token";
  
  [manager POST:url parameters:[oauthRequest createJson] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
    
    OAuthJsonResponse *oauthResponse = [[OAuthJsonResponse alloc] initFromJson:responseObject];
    if (completion) {
      completion(nil, oauthResponse);
    }
    
  } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {

    NSString *message;
    NSData *responseError = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (responseError) {
      NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseError options:kNilOptions error:nil];
      message = responseDictionary[@"message"];
    }
    NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
    NSLog(@"GitHubOAuthApiWrapper:postOAuthRequest: status: %lu error: %@ message: %@", (long)taskResponse.statusCode, error.localizedDescription, message);

    if (completion) {
      completion([self afErrorWithCode:taskResponse.statusCode description:error.localizedDescription message:message], nil);
    }
  }];
}

// repackage AFNetworking error to include code from NSHTTPURLResponse and message, if any
- (NSError *)afErrorWithCode:(NSInteger)code description:(NSString *)description message:(NSString *)message {
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
  userInfo[NSLocalizedDescriptionKey] = description;
  userInfo[NSUnderlyingErrorKey] = message;
  return [[NSError alloc] initWithDomain:kErrorDomainAF code:code userInfo:userInfo];
}

@end
