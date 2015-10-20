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
#import "FileInfo.h"
#import "UserInfo.h"
#import "RepoInfo.h"
#import "CommitJson.h"
#import "FileJson.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

@interface GitHubService ()

@property (strong, readonly, nonatomic) NSString *accessToken;      // saved to Keychain
@property (strong, readonly, nonatomic) UserInfo *user;             // saved to UserDefaults

@end

@implementation GitHubService

- (NSString *)accessToken {
  return [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
}
- (UserInfo *)user {
  return [[UserInfo alloc] initFromUserDefaults];
}

// use of dispatch_once_t with a static onceToken from Effective Objective-C 2.0
+ (instancetype)sharedInstance {
  static GitHubService *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (BOOL)isAuthorized {
  return self.accessToken != nil;
}

+ (void)saveTokenInURLtoKeychain:(NSURL *)url {
  
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
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
  }];
}

- (UserInfo *)getUserInfo:(void(^)(NSError *error, UserInfo *user))completion {
  
  if (self.user) {
    return self.user;
  }
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:NO];
  NSString *url = @"https://api.github.com/user";
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    UserInfo *user = [[UserInfo alloc] initFromJSON:responseObject];
    if (completion) {
      completion(nil, user);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! GET(user name): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    
    if (completion) {
      completion(error, nil);
    }
  }];
  return nil;
}

- (NSString *)ghPagesUrl {
  return [NSString stringWithFormat:@"http://%@.github.io", self.user.name];
}

- (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion {

  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = @"https://api.github.com/user/repos";

  NSDictionary *parameters = @{@"type": @"owner"};
  [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSMutableArray *repos = [[NSMutableArray alloc] init];
    NSArray *reposArray = responseObject;
    for (NSDictionary *repoDict in reposArray) {
      RepoInfo *repo = [[RepoInfo alloc] initFromJSON:repoDict];
      if ([repo.defaultBranch isEqualToString:kBranchName]) {
        [repos addObject:repo];
      }
    }
    if (completion) {
      completion(nil, repos);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! GET(list repos): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);

    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)createRepo:(NSString *)repoName description:(NSString *)description completion:(void(^)(NSError *))completion {
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = @"https://api.github.com/user/repos";

  NSDictionary *parameters = @{@"name": repoName, @"description": description};  //, @"auto_init": @(1)};
  [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"POST(create repo): [%@] responseObject: %@", url, responseObject);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! POST(create repo): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
  }];
}

- (void)getRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:NO];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", self.user.name, repoName];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"GET(repo): [%@] responseObject: %@", url, responseObject);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! GET(repo): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    
    if (completion) {
      completion(error);
    }
  }];
}

- (void)getPages:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:NO];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/pages", self.user.name, repoName];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"GET(repo pages): [%@] responseObject: %@", url, responseObject);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! GET(repo pages): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    
    if (completion) {
      completion(error);
    }
  }];
}

- (void)getRefs:(NSString *)repoName completion:(void(^)(NSError *, CommitJson *))completion {
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:NO];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs/heads", self.user.name, repoName];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"GET(refs): [%@] responseObject: %@", url, responseObject);
    NSArray *objects = responseObject;
    CommitJson *commit = [[CommitJson alloc] initFromJSON:objects.firstObject];
    if (completion) {
      completion(nil, commit);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! GET(refs): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)getFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *, FileJson *))completion {

  NSString *filePath = [file filepathFromTemplateDirectory];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSDictionary *parameters = @{@"ref": kBranchName, @"path": filePath};
  [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"GET(file): [%@] responseObject: %@", url, responseObject);
    FileJson *file = [[FileJson alloc] initFromJSON:responseObject];
    if (completion) {
      completion(nil, file);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSString *message = operation.responseObject[@"message"];
    NSLog(@"GET(file): (%@) %@", file, message);
    //NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    //NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    //NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    
    if (completion) {
      completion(error, nil);
    }
  }];
}

- (void)createBranchForRepo:(NSString *)repoName parentSHA:(NSString *)sha completion:(void(^)(NSError *))completion {
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs", self.user.name, repoName];
  
  NSString *ref = [NSString stringWithFormat:@"refs/heads/%@", kBranchName];
  NSDictionary *parameters = @{@"ref": ref, @"sha": sha};
  [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    //NSLog(@"POST(create branch): [%@] responseObject: %@", url, responseObject);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! POST(create branch): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
  }];
}

- (void)pushIndexHtmlFile:(FileInfo *)file forRepo:(NSString *)repoName withSha:(NSString *)sha completion:(void (^)(NSError *))completion {

  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeFile:localPath withType:file.type];
  NSDictionary *parameters = sha ? @{@"branch": kBranchName, @"sha": sha, @"message": @"index file", @"content": encodedFile} : @{@"branch": kBranchName, @"message": @"index file", @"content": encodedFile};
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

    NSLog(@"PUT(index html): [%@]", filePath);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! PUT(index html): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
  }];
}

- (void)pushJsonFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];

  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeFile:localPath withType:file.type];
  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"InstaSite json data", @"content": encodedFile};
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

    //NSLog(@"PUT(json file): [%@]", filePath);
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! PUT(json file): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
  }];
}

- (void)pushFiles:(NSArray *)files forRepo:(NSString *)repoName completion:(void(^)(NSError *, NSArray *))completion {
  
  FileInfo *file = files.lastObject;
  NSLog(@"(%@) to (%@)", [files.lastObject description], [files.firstObject description]);
  NSMutableArray *filesRemaining = [[NSMutableArray alloc] initWithArray:files];
  [filesRemaining removeLastObject];
  
  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:YES];
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeFile:localPath withType:file.type];

  [self getFile:file forRepo:repoName completion:^(NSError *error, FileJson *fileJson) {
    NSDictionary *parameters = fileJson.sha ? @{@"branch": kBranchName, @"sha": fileJson.sha, @"message": @"supporting file", @"content": encodedFile} : @{@"branch": kBranchName, @"message": @"supporting file", @"content": encodedFile};
    
    [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

      NSLog(@"PUT(file): [%@]", filePath);
      
      double delay = 0.2;
      if (filesRemaining.count == 1) {
        delay = 0.8;
      }
      if (filesRemaining.count > 0) {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [self pushFiles:filesRemaining forRepo:repoName completion:^(NSError *error, NSArray *filesIncludingLastFailed) {
            if (completion) {
              //NSLog(@"FFF");
              completion(error, filesIncludingLastFailed);
              //NSLog(@"GGG");
            }
          }];
        //});
      } else {
        if (completion) {
          //NSLog(@"DDD");
          completion(nil, nil);
          //NSLog(@"EEE");
        }
      }
      
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      
      NSLog(@"Error! PUT(file): [%@] error: %@", url, error.localizedDescription);
      NSString *message = operation.responseObject[@"message"];
      NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
      NSString *detail = error.userInfo[@"NSLocalizedDescription"];
      NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
      if (completion) {
        [filesRemaining addObject:file];
        //NSLog(@"HHH");
        completion(error, filesRemaining);
        //NSLog(@"III");
      }
    }];
  }];
}

- (AFHTTPRequestOperationManager *)createManagerWithSerializer:(BOOL)jsonSerializer {
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  if (jsonSerializer) {
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:self.accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
  } else {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:self.accessToken forHTTPHeaderField:@"Authorization"];
    manager.requestSerializer = requestSerializer;
  }
  return manager;
}

@end
