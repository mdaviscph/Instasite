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

    //AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    //responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    //_manager.responseSerializer = responseSerializer;
    
    _code = code;
    _clientId = clientId;
    _clientSecret = clientSecret;
  }
  return self;
}

- (void)retrieveTokenWithCompletion:(void (^)(NSError *error, NSString *token))finalCompletion {
  
  OAuthJsonRequest *oauthRequest = [[OAuthJsonRequest alloc] initWithCode:self.code clientId:self.clientId clientSecret:self.clientSecret];
  [self.oauthApiWrapper postOAuthRequest:oauthRequest usingManager:self.manager completion:^(NSError *error, OAuthJsonResponse *oauthResponse) {

    // TODO - alert popover?
    if (error) {
      NSLog(@"Error! GitHubAccessToken:retrieveTokenWithCompletion:");
    }
    if (finalCompletion) {
      finalCompletion(error, oauthResponse.accessToken);
    }
  }];
}

@end
