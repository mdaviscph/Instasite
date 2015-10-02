//
//  FileJson.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileJson.h"

@implementation FileJson

- (instancetype)initWithPath:(NSString *)path mode:(NSString *)mode type:(NSString *)type sha:(NSString *)sha content:(NSString *)content {
  self = [super init];
  if (self) {
    _path = path;
    _mode = mode;
    _type = type;
    _sha = sha;
    _content = content;
  }
  return self;
}

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha content:(NSString *)content {
  return [self initWithPath:path mode:@"100644" type:@"blob" sha:sha content:content];
}

- (NSDictionary *)createJson {
  if (self.sha) {
    return @{@"path":self.path, @"mode":self.mode, @"type":self.type, @"sha":self.sha, @"content":self.content};
  }
  return @{@"path":self.path, @"mode":self.mode, @"type":self.type, @"content":self.content};
}

@end
