//
//  CommitJson.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CommitJson.h"

@implementation CommitJson

- (instancetype)initFromJSON:(NSDictionary *)json {
  self = [super init];
  if (self) {
    NSDictionary *object = json[@"object"];
    if (!object) {
      object = json;
    }
    _objectSHA = object[@"sha"];
    _objectType = object[@"type"];
    _objectUrl = object[@"url"];
  }
  return self;
}

@end
