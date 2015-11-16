//
//  CommitTreeJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CommitTreeJsonResponse.h"

@implementation CommitTreeJsonResponse

- (instancetype)initFromJson:(NSDictionary *)jsonDict {
  self = [super init];
  if (self) {
    _sha = jsonDict[@"sha"];
    if (!_sha) {
      return nil;
    }
    NSDictionary *treeDict = jsonDict[@"tree"];
    if (treeDict) {
      _treeSha = treeDict[@"sha"];
    }
  }
  return self;
}

@end
