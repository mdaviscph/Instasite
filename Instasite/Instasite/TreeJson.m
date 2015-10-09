//
//  TreeJson.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TreeJson.h"

@implementation TreeJson

- (instancetype)initFromJSON:(NSDictionary *)json {
  self = [super init];
  if (self) {
    NSDictionary *author = json[@"author"];
    NSDictionary *committer = json[@"committer"];
    NSDictionary *tree = json[@"tree"];
    
    _commitSHA = json[@"sha"];
    if (author) {
      _authorName = author[@"name"];
      _authorEmail = author[@"email"];
    }
    if (committer) {
      _committerName = committer[@"name"];
      _committerEmail = committer[@"email"];
    }
    if (tree) {
      _treeSHA = tree[@"sha"];
      _treeUrl = tree[@"url"];
    }
  }
  return self;
}

@end
