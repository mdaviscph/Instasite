//
//  GitHubPullService.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubPullService.h"
#import "GitHubService.h"
#import "Keys.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>
#import "Constants.h"

@implementation GitHubPullService

+ (void)getJSONFromGithub:(NSString *)repoName email:(NSString *)email templateName:(NSString *)templateName completionHandler:(void (^)(NSError *))completionHandler {
  
  [GitHubService getUsernameFromGithub:^(NSError *error, NSString *username) {
    
    NSString *accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
    
    NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/%@/contents/index.html", username, repoName,email];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = serializer;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"json"];
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:0 error:nil];
    
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary *committer = @{@"name": username, @"email": email};
    NSDictionary *json = @{@"branch": @"gh-pages", @"message": @"my commit", @"committer": committer, @"content": baseString};
    
    [manager PUT:baseURL parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      completionHandler(nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      completionHandler(error);
    }];
  }];
  
}

@end
