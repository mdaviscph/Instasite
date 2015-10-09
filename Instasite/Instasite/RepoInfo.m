//
//  RepoInfo.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoInfo.h"

@implementation RepoInfo

- (instancetype)initFromJSON:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _name = json[@"name"];
    _fullName = json[@"full_name"];
    _aDescription = json[@"description"];
    _htmlURL = json[@"html_url"];
    _defaultBranch = json[@"default_branch"];
  }
  return self;
}

@end
