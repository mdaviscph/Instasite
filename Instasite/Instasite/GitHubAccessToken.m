//
//  GitHubAccessToken.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubAccessToken.h"
#import "GitHubOAuthApiWrapper.h"
#import "OAuthJsonRequest.h"
#import "OAuthJsonResponse.h"
#import "Constants.h"
#import "TypeDefsEnums.h"
#import <AFNetworking/AFNetworking.h>

@interface GitHubAccessToken ()

@property (strong, nonatomic) GitHubOAuthApiWrapper *oauthApiWrapper;
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *clientSecret;

@end

@implementation GitHubAccessToken

- (instancetype)initWithCode:(NSString *)code clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
  self = [super init];
  if (self) {
    _oauthApiWrapper = [[GitHubOAuthApiWrapper alloc] init];
    
    _manager = [AFHTTPSessionManager manager];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    _manager.requestSerializer = requestSerializer;

    _code = code;
    _clientId = clientId;
    _clientSecret = clientSecret;
  }
  return self;
}

- (void)retrieveTokenWithCompletion:(void (^)(NSError *error, NSString *token))finalCompletion {
  
  OAuthJsonRequest *oauthRequest = [[OAuthJsonRequest alloc] initWithCode:self.code clientId:self.clientId clientSecret:self.clientSecret];
  [self.oauthApiWrapper postOAuthRequest:oauthRequest usingManager:self.manager completion:^(NSError *error, OAuthJsonResponse *oauthResponse) {

    if (error && finalCompletion) {
      finalCompletion([self ourErrorWithCode:error.code description:@"Unable to complete GitHub authorization request." message:@"Please retry the operation."], nil);
    } else if (finalCompletion) {
      finalCompletion(nil, oauthResponse.accessToken);
    }
  }];
}

// repackage error to include project specific code and retry suggestion, if any
- (NSError *)ourErrorWithCode:(NSInteger)code description:(NSString *)description message:(NSString *)message {
  NSInteger ourCode;
  switch (code) {
    case 401:
      ourCode = ErrorCodeNotAuthorized;
      break;
    case 404:
      ourCode = ErrorCodeEntityNotFound;
      break;
    case 422:
      ourCode = ErrorCodeOperationIncomplete;
      break;
    default:
      ourCode = ErrorCodeUnknownError;
      break;
  }
  NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
  userInfo[NSLocalizedDescriptionKey] = description;
  userInfo[NSLocalizedRecoverySuggestionErrorKey] = message;
  return [[NSError alloc] initWithDomain:kErrorDomain code:ourCode userInfo:userInfo];
}

@end
