//
//  TreeJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TreeJsonRequest.h"
#import "FileJsonRequest.h"
#import "FileJsonResponse.h"

@implementation TreeJsonRequest

- (instancetype)initWithFileList:(FileJsonRequestArray *)files existingFileList:(FileJsonResponseArray *)existingFiles {
  self = [super init];
  if (self) {
    _files = files;
    _existingFiles = existingFiles;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *jsonFiles = [[NSMutableDictionary alloc] init];
 
  // for existing files: must include file (path and sha) or file will be removed from tree
  for (FileJsonResponse *existingFile in self.existingFiles) {
    if ([existingFile.type isEqualToString:@"blob"]) {
      FileJsonRequest *fileRequest = [[FileJsonRequest alloc] initWithPath:existingFile.path sha:existingFile.sha];
      jsonFiles[existingFile.path] = [fileRequest createJson];
    }
  }
  // add new or replace existing
  for (FileJsonRequest *file in self.files) {
    //if ([file.path hasPrefix:@"img"] || [file.path hasPrefix:@"index"]) {
    //  NSLog(@"replacing %@ old: %@ new: %@", file.path, jsonFiles[file.path], [file createJson]);
    //}
    jsonFiles[file.path] = [file createJson];
  }

  jsonDict[@"tree"] = jsonFiles.allValues;
  
  return jsonDict;
}

@end
