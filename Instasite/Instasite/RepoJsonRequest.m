//
//  RepoJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoJsonRequest.h"

@implementation RepoJsonRequest

- (instancetype)initWithName:(NSString *)name comment:(NSString *)comment {
  self = [super init];
  if (self) {
    _name = name;
    _comment = comment;
    _commitReadme = YES;
    _license = @"mit";
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"name"] = self.name;
  jsonDict[@"description"] = self.comment;
  jsonDict[@"auto_init"] = self.commitReadme ? @(1) : @(0);
  jsonDict[@"license_template"] = self.license;
  
  return jsonDict;
}

@end
