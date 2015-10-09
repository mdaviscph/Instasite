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
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

@interface GitHubService ()

@property (strong, nonatomic) NSString *accessToken;      // saved to Keychain
@property (strong, nonatomic) UserInfo *user;             // saved to UserDefaults

@end

@implementation GitHubService

// use of dispatch_once_t with a static onceToken from Effective Objective-C 2.0
+ (instancetype)sharedInstance {
  static GitHubService *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
    [sharedInstance initializeInstance];
  });
  return sharedInstance;
}

- (void)initializeInstance {
  self.accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  self.user = [[UserInfo alloc] initFromUserDefaults];
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

  NSString *url = @"https://api.github.com/user";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
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

- (void)getReposWithCompletion:(void(^)(NSError *error, NSArray *repos))completion {
  
  NSString *url = @"https://api.github.com/user/repos";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
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
  
  NSString *url = @"https://api.github.com/user/repos";
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSDictionary *parameters = @{@"name": repoName, @"description": description, @"auto_init": @(1)};
  
  [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"POST(create repo): [%@] responseObject: %@", url, responseObject);
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
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@", self.user.name, repoName];

  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"GET(repo): [%@] responseObject: %@", url, responseObject);
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
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/pages", self.user.name, repoName];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
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
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs/heads", self.user.name, repoName];

  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:false];
  
  [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"GET(refs): [%@] responseObject: %@", url, responseObject);
    
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

- (void)createBranchForRepo:(NSString *)repoName parentSHA:(NSString *)sha completion:(void(^)(NSError *))completion {
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/git/refs", self.user.name, repoName];
  NSString *ref = [NSString stringWithFormat:@"refs/heads/%@", kBranchName];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSDictionary *parameters = @{@"ref": ref, @"sha": sha};
  
  [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
    NSLog(@"POST(create branch): [%@] responseObject: %@", url, responseObject);
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

- (void)pushIndexHtmlFile:(FileInfo *)file forRepo:(NSString *)repoName completion:(void (^)(NSError *))completion {

  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  NSString *encodedFile = [FileEncodingService encodeHTML:localPath];
  
  NSDictionary *parameters = @{@"branch": kBranchName, @"message": @"index file", @"content": encodedFile};
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //NSLog(@"PUT(html): [%@]", url);
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
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeJSON:localPath];
  // possible for there to not be a userInput JSON file if no text entered
  if (!encodedFile) {
    completion(nil);
    return;
  }
  
  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"InstaSite json data", @"content": encodedFile};
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //NSLog(@"PUT(json): [%@]", url);
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

- (void)pushImageFiles:(NSMutableArray *)files forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {

  FileInfo *file = files.lastObject;
  [files removeLastObject];
  
  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeImage:localPath];
  
  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"image file", @"content": encodedFile};
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSLog(@"PUT(image file): local: [%@] url: [%@]", localPath, url);
    
    if (files.count > 0) {
      [self pushImageFiles:files forRepo:repoName completion:^(NSError *error) {
        if (completion) {
          completion(error);
        }
      }];
    }
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! PUT(image file): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
  }];
}

- (void)pushSupportingFiles:(NSMutableArray *)files forRepo:(NSString *)repoName completion:(void(^)(NSError *))completion {
  
  FileInfo *file = files.lastObject;
  [files removeLastObject];
  
  NSString *localPath = [file filepathIncludingDocumentsDirectory];
  NSString *filePath = [file filepathFromTemplateDirectory];
  
  NSString *url = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/contents/%@", self.user.name, repoName, filePath];
  
  NSString *encodedFile = [FileEncodingService encodeSupportingFile:localPath];
  
  NSDictionary *parameters = @{@"branch": kBranchName, @"message":@"supporting file", @"content": encodedFile};
  
  AFHTTPRequestOperationManager *manager = [self createManagerWithSerializer:true];
  
  [manager PUT:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSLog(@"PUT(supporting file): local: [%@] url: [%@]", localPath, url);
    
    if (files.count > 0) {
      [self pushSupportingFiles:files forRepo:repoName completion:^(NSError *error) {
        if (completion) {
          completion(error);
        }
      }];
    }
    if (completion) {
      completion(nil);
    }
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
    NSLog(@"Error! PUT(supporting file): [%@] error: %@", url, error.localizedDescription);
    NSString *message = operation.responseObject[@"message"];
    NSString *failedUrl = error.userInfo[@"NSErrorFailingURLKey"];
    NSString *detail = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"message: %@ url: [%@] detail: %@", message, failedUrl, detail);
    if (completion) {
      completion(error);
    }
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
