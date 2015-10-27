//
//  RefJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RefJsonRequest.h"

@implementation RefJsonRequest

- (instancetype)initWithRef:(NSString *)ref sha:(NSString *)sha {
  self = [super init];
  if (self) {
    _ref = ref;
    _sha = sha;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"ref"] = self.ref;
  jsonDict[@"sha"] = self.sha;
  
  return jsonDict;
}

@end
