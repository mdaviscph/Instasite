//
//  TreeJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TreeJsonResponse.h"
#import "FileJsonResponse.h"

@implementation TreeJsonResponse

- (instancetype)initFromJson:(NSDictionary *)jsonDict {
  self = [super init];
  if (self) {
    _sha = jsonDict[@"sha"];
    if (!_sha) {
      return nil;
    }
    NSArray *treeArray = jsonDict[@"tree"];
    FileJsonResponseMutableArray *jsonFiles = [[FileJsonResponseMutableArray alloc] init];
    for (NSDictionary *fileDict in treeArray) {
      FileJsonResponse *file = [[FileJsonResponse alloc] initFromJson:fileDict];
      [jsonFiles addObject:file];
    }
    _files = [[FileJsonResponseArray alloc] initWithArray:jsonFiles];
  }
  return self;
}

@end
