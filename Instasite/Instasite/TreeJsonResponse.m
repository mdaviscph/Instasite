//
//  TreeJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TreeJsonResponse.h"

@implementation TreeJsonResponse

- (instancetype)initFromJson:(NSDictionary *)jsonDict {
  self = [super init];
  if (self) {
    _sha = jsonDict[@"sha"];
    if (!_sha) {
      return nil;
    }
  }
  return self;
}

@end
