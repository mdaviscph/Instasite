//
//  Repo.m
//  Instasite
//
//  Created by mike davis on 11/4/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "Repo.h"

@implementation Repo

- (instancetype)initWithName:(NSString *)name description:(NSString *)description owner:(NSString *)owner {
  self = [super init];
  if (self) {
    _name = name;
    if (!_name) {
      return nil;
    }
    _aDescription  = description;
    _owner = owner;
  }
  return self;
}

@end
