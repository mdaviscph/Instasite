//
//  FileInfo.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileInfo.h"

@implementation FileInfo

- (instancetype)initWithFileName:(NSString *)name extension:(NSString *)extension type:(FileType)type relativePath:(NSString *)path templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory {
  if (self = [super init]) {
    _name = name.length > 0 ? name : nil;
    _extension = extension.length > 0 ? extension : nil;
    _type = type;
    _path = path.length > 0 ? path : nil;
    _templateDirectory = templateDirectory;
    _documentsDirectory = documentsDirectory;
  }
  return self;
}

// stringByAppendingPathComponents handles nil and empty string correctly but stringByAppendingPathExtension does not
- (NSString *)filepathIncludingDocumentsDirectory {
  NSString *filepath = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  filepath = [filepath stringByAppendingPathComponent:self.path];
  filepath = [filepath stringByAppendingPathComponent:self.name];
  filepath = self.extension ? [filepath stringByAppendingPathExtension:self.extension] : filepath;
  return filepath;
}

- (NSString *)filepathFromTemplateDirectory {
  NSString *filepath = self.path ? [self.path stringByAppendingPathComponent:self.name] : self.name;
  if (filepath && self.extension) {
    filepath = [filepath stringByAppendingPathExtension:self.extension];
  } else if (self.extension) { // only an extension (e.g., .nojekyll)
    filepath = [@"." stringByAppendingString:self.extension];
  }  
  return filepath;
}

- (NSString *)mimeTypeFromType {
  switch (self.type) {
    case IndexHtml:
      return @"text/html";
    case UserInputJson:
      return @"text/plain";
    case Other:
      return @"text/plain";
    case ImageJpeg:
      return @"image/jpeg";
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"[%@][%@.%@]", self.path?self.path:@"", self.name, self.extension];
}

@end
