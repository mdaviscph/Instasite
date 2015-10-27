//
//  FileJsonRequest.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileJsonRequest.h"

@implementation FileJsonRequest

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha mode:(NSString *)mode type:(NSString *)type encoding:(NSString *)encoding content:(NSString *)content {
  self = [super init];
  if (self) {
    _path = path;
    _sha = sha;
    _mode = mode;
    _type = type;
    _encoding = encoding;
    _content = content;
  }
  return self;
}

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha base64content:(NSString *)content {
  return [self initWithPath:path sha:sha mode:@"100644" type:@"blob" encoding:@"base64" content:content];
}

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha {
  return [self initWithPath:path sha:sha mode:@"100644" type:@"blob" encoding:nil content:nil];
}

- (NSDictionary *)createJson {
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"path"]     = self.path;
  jsonDict[@"sha"]      = self.sha;
  jsonDict[@"mode"]     = self.mode;
  jsonDict[@"type"]     = self.type;
  jsonDict[@"encoding"] = self.encoding;
  jsonDict[@"content"]  = self.content;
  return jsonDict;
}

@end
