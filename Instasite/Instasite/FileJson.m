//
//  FileJson.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileJson.h"

@implementation FileJson

- (instancetype)initWithPath:(NSString *)path mode:(NSString *)mode type:(NSString *)type encoding:(NSString *)encoding sha:(NSString *)sha content:(NSString *)content {
  self = [super init];
  if (self) {
    _path = path;
    _mode = mode;
    _type = type;
    _encoding = encoding;
    _sha = sha;
    _content = content;
  }
  return self;
}

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha content:(NSString *)content {
  return [self initWithPath:path mode:@"100644" type:@"blob" encoding:@"base64" sha:sha content:content];
}

- (instancetype)initFromJSON:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _path = json[@"path"];
    _mode = json[@"mode"];
    _type = json[@"type"];
    _encoding = json[@"encoding"];
    _sha = json[@"sha"];
    _content = json[@"content"];
  }
  return self;
}

- (NSDictionary *)createJson {
  NSMutableDictionary *jsonDict;
  jsonDict[@"path"] = self.path;
  jsonDict[@"mode"] = self.mode;
  jsonDict[@"type"] = self.type;
  jsonDict[@"encoding"] = self.encoding;
  jsonDict[@"sha"] = self.sha;
  jsonDict[@"content"] = self.content;
  return jsonDict;
}

@end
