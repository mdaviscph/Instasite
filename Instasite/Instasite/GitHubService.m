//
//  GitHubService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubService.h"
#import "FileEncodingService.h"
#import "Keys.h"
#import "Constants.h"
#import "ParseJSONService.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

@implementation GitHubService

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
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/user/repos"];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSDictionary *repo = @{@"name": repoNameInput, @"description": descriptionInput};
  
  [manager POST:url parameters:repo success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"Result: %@", responseObject);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error: %@", operation.responseObject);
  }];
  
}

+ (void)pushFilesToGithub:(NSString *)repoName indexHtmlFile:(NSString *)indexHtmlFile email:(NSString *)userEmail completionHandler:(void(^) (NSError *))completionHandler {
  
  [self getUsernameFromGithub:^(NSError *error, NSString *username) {
    
    
    NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/index.html", username, repoName];
    
    AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:indexHtmlFile ofType:@"html"];
    
    NSString *encodedFile = [FileEncodingService encodeHTML:filePath];
    
    NSDictionary *committer = @{@"name": username, @"email": userEmail};
    NSDictionary *json = @{@"branch": @"gh-pages", @"message": @"my commit", @"committer": committer, @"content": encodedFile};
    
    [manager PUT:baseURL parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      completionHandler(nil);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      completionHandler(error);
    }];
  }];
  
}

+ (void)pushImagesToGithub:(NSString *)imageName imagePath:(NSString *)imagePath email:(NSString *)userEmail forRepo:(NSString *)repoName {
  [self getUsernameFromGithub:^(NSError *error, NSString *username) {
    
    NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/img/", username, repoName];
    
    NSString *encodedImage = [FileEncodingService encodeImage:imagePath];
    
    NSDictionary *committer = @{@"name": username, @"email": userEmail};
    NSDictionary *json = @{@"branch": @"gh-pages", @"message": @"Files Push", @"committer": committer, @"content" : encodedImage};
    
    AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", baseURL,imageName];
    [manager PUT:url parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"Failure: %@", operation.responseObject);
    }];
  }];
  
}

+ (void)pushCSSToGithub:(NSString *)fileName cssPath:(NSString *)cssPath email:(NSString *)userEmail forRepo:(NSString *)repoName {
  
  [self getUsernameFromGithub:^(NSError *error, NSString *username) {
    if (username != nil) {
      NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/css/",username,repoName];
      NSString *encodedCSS = [FileEncodingService encodeHTML:cssPath];
      NSString *url = [NSString stringWithFormat:@"%@%@",baseURL,fileName];
      
      NSDictionary *committer = @{@"name": username, @"email": userEmail};
      NSDictionary *json = @{@"branch": kBranchName, @"message":@"Push CSS", @"committer": committer, @"content": encodedCSS};
      
      AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
      
      [manager PUT:url parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
      } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
      }];
    }
  }];
  
}

+ (void)pushJSONToGithub:(NSString *)jsonPath email:(NSString *)userEmail forRepo:(NSString *)repoName {
  [self getUsernameFromGithub:^(NSError *error, NSString *username) {
    if (username != nil) {
      NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@.%@",username,repoName,kTemplateJsonFilename,kTemplateJsonFiletype];
      NSString *encodedJSON = [FileEncodingService encodeHTML:jsonPath];

      
      NSDictionary *committer = @{@"name": username, @"email": userEmail};
      NSDictionary *json = @{@"branch": kBranchName, @"message":@"Push JSON", @"committer": committer, @"content": encodedJSON};
      
      AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
      
      [manager PUT:baseURL parameters:json success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
      } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
      }];
    }
  }];
}

+ (void)getUsernameFromGithub:(void (^) (NSError *error, NSString *username))completionHandler {
  
  NSString *url = @"https://api.github.com/user";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSLog(@"Response: %@", responseObject);
    [ParseJSONService getGithubUsernameFromJSON:responseObject completionHandler:^(NSString *username) {
      completionHandler(nil, username);
    }];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error: %@", operation.responseObject);
  }];
}

+ (AFHTTPRequestOperationManager *)createManagerWithSerializer:(BOOL)jsonSerializer {
  
  NSString *accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  if (jsonSerializer) {
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
  } else {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
  }
  
  return manager;
}
@end
