//
//  FileInfo.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileInfo.h"

@implementation FileInfo

- (instancetype)initWithFileName:(NSString *)name extension:(NSString *)extension type:(FileType)type relativePath:(NSString *)path remoteDirectory:(NSString *)remoteDirectory localDirectory:(NSString *)localDirectory {
  if (self = [super init]) {
    _name = name.length > 0 ? name : nil;
    _extension = extension.length > 0 ? extension : nil;
    _type = type;
    _path = path.length > 0 ? path : nil;
    _remoteDirectory = remoteDirectory;
    _localDirectory = localDirectory;
  }
  return self;
}

// stringByAppendingPathComponents handles nil and empty string correctly but stringByAppendingPathExtension does not
- (NSString *)filepathIncludingLocalDirectory {
  NSString *filepath = [self.localDirectory stringByAppendingPathComponent:self.remoteDirectory];
  filepath = [filepath stringByAppendingPathComponent:self.path];
  filepath = [filepath stringByAppendingPathComponent:self.name];
  filepath = self.extension ? [filepath stringByAppendingPathExtension:self.extension] : filepath;
  return filepath;
}

- (NSString *)filepathFromRemoteDirectory {
  NSString *filepath = self.path ? [self.path stringByAppendingPathComponent:self.name] : self.name;
  if (filepath && self.extension) {
    filepath = [filepath stringByAppendingPathExtension:self.extension];
  } else if (self.extension) { // only an extension (e.g., .nojekyll)
    filepath = [@"." stringByAppendingString:self.extension];
  }  
  return filepath;
}

- (NSString *)description {
  if (self.name && self.extension) {
    return [self.name stringByAppendingPathExtension:self.extension];
  } else if (self.extension) { // only an extension (e.g., .nojekyll)
    return [@"." stringByAppendingString:self.extension];
  }
  return self.name;
}

@end
