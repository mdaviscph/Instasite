//
//  FileInfo.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileInfo.h"

@implementation FileInfo

- (instancetype)initWithFileName:(NSString *)name fileType:(NSString *)type relativePath:(NSString *)path templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory {
  if (self = [super init]) {
    _name = name;
    _type = type.length > 0 ? type : nil;
    _path = path.length > 0 ? path : nil;
    _templateDirectory = templateDirectory;
    _documentsDirectory = documentsDirectory;
  }
  return self;
}

- (NSString *)filepathIncludingDocumentsDirectory {
  NSString *filepath = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  filepath = self.path ? [filepath stringByAppendingPathComponent:self.path] : filepath;
  filepath = [filepath stringByAppendingPathComponent:self.name];
  filepath = self.type ? [filepath stringByAppendingPathExtension:self.type] : filepath;
  return filepath;
}

- (NSString *)filepathFromTemplateDirectory {
  NSString *filepath = self.path ? [self.path stringByAppendingPathComponent:self.name] : self.name;
  filepath = self.type ? [filepath stringByAppendingPathExtension:self.type] : filepath;
  return filepath;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%@][%@.%@]", self.path?self.path:@"", self.name, self.type];
}

@end
