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

+ (void)getJSONFromGithub:(NSString *)repoName email:(NSString *)email completion:(void (^)(NSError *))completion {
  
  [GitHubService getUsernameFromGithub:^(NSError *error, NSString *username) {
    
    NSString *accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
    
    NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/instasite.json", username, repoName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = serializer;

    [manager GET:baseURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"Github Error: %@", operation.responseObject);
    }];
  }];
  
}

@end
