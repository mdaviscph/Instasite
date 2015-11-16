//
//  CommitTreeJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CommitTreeJsonRequest.h"

@implementation CommitTreeJsonRequest

- (instancetype)initWithTreeSha:(NSString *)treeSha message:(NSString *)message parentSha:(NSString *)parentSha {
  self = [super init];
  if (self) {
    _treeSha = treeSha;
    _message = message;
    _parentSha = parentSha;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"tree"] = self.treeSha;
  jsonDict[@"message"] = self.message;
  if (self.parentSha) {
    jsonDict[@"parents"] = @[self.parentSha];
  }
  return jsonDict;
}

@end
