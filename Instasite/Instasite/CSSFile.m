//
//  CSSFile.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CSSFile.h"

@implementation CSSFile
- (instancetype)initWithPath:(NSString *)path andFileName:(NSString *)fileName andDocumentsDirectory:(NSString *)directory {
  if (self = [super init]) {
    _filePath = path;
    _fileName = fileName;
    _documentsDirectory = directory;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%@][%@]", self.filePath, self.fileName];
}
@end
