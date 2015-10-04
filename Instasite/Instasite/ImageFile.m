//
//  ImageFile.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImageFile.h"

@implementation ImageFile

- (instancetype)initWithFileName:(NSString *)fileName filePath:(NSString *)filePath templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory {
  if (self = [super init]) {
    _fileName = fileName;
    _filePath = filePath;
    _templateDirectory = templateDirectory;
    _documentsDirectory = documentsDirectory;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%@][%@]", self.filePath, self.fileName];
}

@end
