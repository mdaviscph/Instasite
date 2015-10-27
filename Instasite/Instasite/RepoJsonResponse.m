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
    NSDictionary *owner = json[@"owner"];
    if (owner) {
      _owner = owner[@"login"];
    } else {
      return nil;
    }
  }
  return self;
}

@end
