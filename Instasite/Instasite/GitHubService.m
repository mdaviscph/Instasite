//
//  GitHubService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubService.h"
#import "Keys.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

@implementation GitHubService

//TODO - Fix AFNetworking
//TODO - Store Access Token in Keychain

+ (void)exchangeCodeInURL:(NSURL *)url {
  
  NSString *code = url.query;
  NSString *requestURL = [NSString stringWithFormat:@"https://github.com/login/oauth/access_token?%@",code];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
  NSSet *acceptable = [NSSet setWithObjects:@"application/x-www-form-urlencoded", nil];
  serializer.acceptableContentTypes = acceptable;
  manager.responseSerializer = serializer;
  
  NSDictionary *parameters = @{@"code": code, @"client_id": kClientId, @"client_secret": kClientSecret};
  
  [manager POST:requestURL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSString *parameters = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSArray *substrings = [parameters componentsSeparatedByString:@"&"];
    NSString *accessTokenString = substrings[0];
    
    substrings = [accessTokenString componentsSeparatedByString:@"="];
    NSString *accessToken = [substrings lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error: %@", error);
  }];
  
}

@end
