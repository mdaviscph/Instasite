//
//  FileJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileJsonResponse.h"

@implementation FileJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _path = json[@"path"];
    _sha  = json[@"sha"];
    _mode = json[@"mode"];
    _type = json[@"type"];
  }
  return self;
}

@end
