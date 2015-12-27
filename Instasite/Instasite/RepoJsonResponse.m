//
//  RepoJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoJsonResponse.h"

@implementation RepoJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _name          = json[@"name"];
    if (!_name) {
      return nil;
    }
    _fullName      = json[@"full_name"];
    _aDescription  = json[@"description"];
    _defaultBranch = json[@"default_branch"];
    
    // format of "updated_at": "2015-09-01T15:42:22Z"
    NSString *update = json[@"updated_at"];
    if (update) {
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
      [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
      _updatedAt = [dateFormatter dateFromString:update];
    }

    NSDictionary *owner = json[@"owner"];
    if (owner) {
      _owner = owner[@"login"];
    } else {
      return nil;
    }
    
    _exists = GitHubRepoExists;
  }
  return self;
}

- (instancetype)initWithTest:(GitHubRepoTest)exists {
  self = [super init];
  if (self) {
    _exists = exists;
  }
  return self;
}

@end
