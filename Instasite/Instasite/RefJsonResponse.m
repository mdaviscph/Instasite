//
//  RefJsonResponse.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RefJsonResponse.h"

@implementation RefJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _ref = json[@"ref"];
    if (!_ref) {
      return nil;
    }
    NSDictionary *object = json[@"object"];
    if (object) {
      _objectSha = object[@"sha"];
      _objectType = object[@"type"];
    } else {
      return nil;
    }
  }
  return self;
}

@end
