//
//  TreeJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TreeJsonRequest.h"
#import "FileJsonRequest.h"

@implementation TreeJsonRequest

- (instancetype)initWithFileList:(FileJsonRequestArray *)files {
  self = [super init];
  if (self) {
    _files = files;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  NSMutableArray *jsonFiles = [[NSMutableArray alloc] init];
  for (FileJsonRequest *file in self.files) {
    [jsonFiles addObject:[file createJson]];
  }
  jsonDict[@"tree"] = jsonFiles;
  
  return jsonDict;
}

@end
