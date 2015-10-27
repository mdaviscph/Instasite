//
//  BlobJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "BlobJsonRequest.h"
#import "FileInfo.h"
#import "FileEncodingService.h"

@implementation BlobJsonRequest

- (instancetype)initWithFileInfo:(FileInfo *)file {
  self = [super init];
  if (self) {
    _file = file;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  NSString *localPath = [self.file filepathIncludingLocalDirectory];
  
  NSString *encodedFile = [FileEncodingService encodeFile:localPath withType:self.file.type];
  jsonDict[@"content"] = encodedFile;
  jsonDict[@"encoding"] = @"base64";

  return jsonDict;
}


@end
