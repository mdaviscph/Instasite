//
//  FileJsonRequest.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileJsonRequest.h"

@implementation FileJsonRequest

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha {
  self = [super init];
  if (self) {
    _path = path;
    _sha  = sha;
    _mode = @"100644";
    _type = @"blob";
  }
  return self;
}

- (NSDictionary *)createJson {
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"path"] = self.path;
  jsonDict[@"sha"]  = self.sha;
  jsonDict[@"mode"] = self.mode;
  jsonDict[@"type"] = self.type;
  return jsonDict;
}

@end
