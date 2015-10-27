//
//  UserReposJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "UserReposJsonRequest.h"

@implementation UserReposJsonRequest

- (instancetype)initWithType:(NSString *)type sort:(NSString *)sort direction:(NSString *)direction {
  self = [super init];
  if (self) {
    _type = type;
    _sort = sort;
    _direction = direction;
  }
  return self;
}

- (instancetype)initWithType:(NSString *)type {
  return [self initWithType:type sort:@"full_name" direction:@"asc"];
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"type"] = self.type;
  jsonDict[@"sort"] = self.sort;
  jsonDict[@"direction"] = self.direction;
  
  return jsonDict;
}

@end
