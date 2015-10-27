//
//  CommitTreeJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CommitTreeJsonRequest.h"

@implementation CommitTreeJsonRequest

- (instancetype)initWithSha:(NSString *)sha message:(NSString *)message {
  self = [super init];
  if (self) {
    _sha = sha;
    _message = message;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"tree"] = self.sha;
  jsonDict[@"message"] = self.message;
  
  return jsonDict;
}

@end
