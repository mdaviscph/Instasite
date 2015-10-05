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
#import "RepoJson.h"
#import "Constants.h"
#import "CSSFile.h"
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
    
    NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSArray *substrings = [result componentsSeparatedByString:@"&"];
    NSString *accessTokenExpression = substrings.firstObject;
    
    substrings = [accessTokenExpression componentsSeparatedByString:@"="];
    NSString *accessToken = substrings.lastObject;
    NSString *token = [NSString stringWithFormat:@"token %@", accessToken];
    
    [SSKeychain setPassword:token forService:kSSKeychainService account:kSSKeychainAccount];
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! POST(token request): [%@] error: %@", requestURL, error.localizedDescription);
    NSLog(@"%@", operation.response);
  }];
  
}

+ (void)createRepo:(NSString *)repoName description:(NSString *)description completion:(void(^)(NSError *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/user/repos"];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSDictionary *repo = @{@"name": repoName, @"description": description};
  
  [manager POST:url parameters:repo success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"POST(repo): [%@] responseObject: %@", url, responseObject);
    completion(nil);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! Post(repo): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    completion(error);
  }];
}

+ (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion {
  
  NSString *url = @"https://api.github.com/user/repos";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
  NSDictionary *parameters = @{@"type": @"owner"};
  
  [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSMutableArray *repos = [[NSMutableArray alloc] init];
    NSArray *reposArray = responseObject;
    for (NSDictionary *repoDict in reposArray) {
      RepoJson *repo = [[RepoJson alloc] initFromJSON:repoDict];
      [repos addObject:repo];
    }
    completion(nil, repos);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! GET: [%@] error: %@", url, error.localizedDescription);
    NSLog(@"%@", operation.responseObject[@"message"]);
    completion(error, nil);
  }];
}

+ (void)getUsernameFromGithub:(void(^)(NSError *error, NSString *username))completion {
  
  NSString *url = @"https://api.github.com/user";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSString *username = responseObject[@"login"];
    completion(nil, username);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! GET: [%@] error: %@", url, error.localizedDescription);
    NSLog(@"%@", operation.responseObject[@"message"]);
    completion(error, nil);
  }];
}

+ (void)pushFilesToGithub:(NSString *)repoName indexHtmlFile:(NSString *)indexHtmlFile user:(NSString *)userName email:(NSString *)userEmail completion:(void(^)(NSError *))completion {
  
  NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/index.html", userName, repoName];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSString *filePath = [indexHtmlFile stringByAppendingPathComponent:kTemplateIndexFilename];
  
  filePath = [filePath stringByAppendingPathExtension:kTemplateIndexFiletype];
  
  NSString *encodedFile = [FileEncodingService encodeHTML:filePath];
  
  NSDictionary *committer = @{@"name": userName, @"email": userEmail};
  NSDictionary *parameters = @{@"branch": @"gh-pages", @"message": @"new index.html", @"committer": committer, @"content": encodedFile};
  
  [manager PUT:baseURL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //NSLog(@"PUT(html): [%@]", baseURL);
    completion(nil);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! PUT(html): [%@] error: %@", baseURL, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    completion(error);
  }];
}

+ (void)pushImagesToGithub:(NSString *)imageName imagePath:(NSString *)imagePath user:(NSString *)userName  email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {

  NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/img/", userName, repoName];
  
  NSString *filePath = [imagePath stringByAppendingPathComponent:imageName];
  
  NSString *encodedImage = [FileEncodingService encodeImage:filePath];
  
  NSString *url = [NSString stringWithFormat:@"%@%@", baseURL,imageName];
  
  NSDictionary *committer = @{@"name": userName, @"email": userEmail};
  NSDictionary *parameters = @{@"branch": @"gh-pages", @"message": @"new image", @"committer": committer, @"content" : encodedImage};
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //NSLog(@"PUT(Images): [%@]", url);
    completion(nil);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! PUT(Images): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    completion(error);
  }];
}

+ (void)pushCSSToGithub:(NSMutableArray *)cssFiles user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  CSSFile *cssFile = cssFiles.lastObject;
  [cssFiles removeLastObject];
  
  NSString *localPath = [cssFile.documentsDirectory stringByAppendingPathComponent:cssFile.templateDirectory];
  localPath = cssFile.filePath ? [localPath stringByAppendingPathComponent:cssFile.filePath] : localPath;
  localPath = [localPath stringByAppendingPathComponent:cssFile.fileName];
  
  NSString *filePath = cssFile.filePath ? [cssFile.filePath stringByAppendingPathComponent:cssFile.fileName] : cssFile.fileName;
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", userName, repoName, filePath];
  
  NSString *encodedCSS = [FileEncodingService encodeCSS:localPath];
  
  NSDictionary *committer = @{@"name": userName, @"email": userEmail};
  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"new supporting file", @"committer": committer, @"content": encodedCSS};
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSLog(@"PUT(CSS): local: [%@] url: [%@]", localPath, url);
    
    if (cssFiles.count > 0) {
      [GitHubService pushCSSToGithub:cssFiles user:userName email:userEmail forRepo:repoName completion:^(NSError *error) {
        completion(error);
      }];
    }
    completion(nil);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"Error! PUT(CSS): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    completion(error);
  }];
}

//+ (void)pushCSSToGithub:(NSString *)fileName cssPath:(NSString *)cssPath finalPath:(NSString *)localPath user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
//
//  NSArray *fileLocation = [cssPath componentsSeparatedByString:@"/"];
//  NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@/",userName, repoName, [fileLocation lastObject]];
//  
//  NSString *encodedCSS = [FileEncodingService encodeCSS:localPath];
//  
//  NSString *url = [NSString stringWithFormat:@"%@%@",baseURL,fileName];
//  
//  NSDictionary *committer = @{@"name": userName, @"email": userEmail};
//  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"new supporting file", @"committer": committer, @"content": encodedCSS};
//  
//  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
//  
//  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//    //NSLog(@"PUT(CSS): [%@]", url);
//    
//  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//    NSLog(@"Error! PUT(CSS): [%@] error: %@", url, error.localizedDescription);
//    NSString *message = operation.responseObject[@"message"];
//    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
//    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
//    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
//  }];
//}

+ (void)pushJSONToGithub:(NSString *)jsonPath user:(NSString *)userName email:(NSString *)userEmail forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  [self getUsernameFromGithub:^(NSError *error, NSString *username) {
    if (username != nil) {
      NSString *baseURL = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@.%@",username,repoName,kTemplateJsonFilename,kTemplateJsonFiletype];
      
      NSString *filePath = [jsonPath stringByAppendingPathComponent:kTemplateJsonFilename];
      
      filePath = [filePath stringByAppendingPathExtension:kTemplateJsonFiletype];
      
      NSString *encodedJSON = [FileEncodingService encodeJSON:filePath];
      
      NSDictionary *committer = @{@"name": username, @"email": userEmail};
      NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"new userInput json data", @"committer": committer, @"content": encodedJSON};
      
      AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
      
      [manager PUT:baseURL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //NSLog(@"PUT(json): [%@]", baseURL);
        completion(nil);
        
      } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"Error! PUT(json): [%@] error: %@", baseURL, error.localizedDescription);
        NSString *message = operation.responseObject[@"message"];
        NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
        NSString *detail = error.userInfo[@"NSLocalizedDescription"];
        NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
        completion(error);
      }];
    }
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
