//
//  GitHubService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubService.h"
#import "Keys.h"
#import "Constants.h"
#import "ParseJSONService.h"
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
    NSString *token = [NSString stringWithFormat:@"token %@", accessToken];
    
    [SSKeychain setPassword:token forService:kSSKeychainService account:kSSKeychainAccount];
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error: %@", error);
  }];
  
}

+(void)serviceForRepoNameInput:(NSString *)repoNameInput descriptionInput:(NSString *)descriptionInput completionHandler:(void (^) (NSError *))completionHandler{
  
  NSString *access_token = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/user/repos"];
  
  // Test comment
  //NSString *privateRepo;
  
//  if (privacy) {
//    privateRepo = @"true";
//  } else {
//    privateRepo = @"false";
//  }
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
  
  [serializer setValue:access_token forHTTPHeaderField:@"Authorization"];
  manager.requestSerializer = serializer;
  
  NSDictionary *repo = @{@"name": repoNameInput, @"description": descriptionInput};
  
  [manager POST:url parameters:repo success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"Result: %@", responseObject);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error: %@", operation.responseObject);
  }];
  
}

+ (void)pushFilesToGithub:(NSString *)repoName username:(NSString *)username templateName:(NSString *)templateName completionHandler:(void(^) (NSError *))completionHandler {
  NSString *accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  
  NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/index.html", username, repoName];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
  [serializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
  manager.requestSerializer = serializer;
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html"];
  NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:0 error:nil];
  
  NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  
  NSDictionary *committer = @{@"name": @"sam", @"email": @"swilskey41@gmail.com"};
  NSDictionary *json = @{@"branch": @"gh-pages", @"message": @"my commit", @"committer": committer, @"content": baseString};
  
  [manager PUT:baseURL parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    completionHandler(nil);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    completionHandler(error);
  }];
  
}

+ (void)getUsernameFromGithub:(void (^) (NSError *error, NSString *username))completionHandler {
  NSString *accesstoken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  
  NSString *url = @"https://api.github.com/user";
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
  [requestSerializer setValue:accesstoken forHTTPHeaderField:@"Authorization"];
  manager.requestSerializer = requestSerializer;
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSLog(@"Response: %@", responseObject);
    [ParseJSONService getGithubUsernameFromJSON:responseObject completionHandler:^(NSString *username) {
      completionHandler(nil, username);
    }];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error: %@", operation.responseObject);
  }];
}

@end
