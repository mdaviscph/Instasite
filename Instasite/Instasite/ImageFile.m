//
//  ImageFile.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImageFile.h"

@implementation ImageFile
- (instancetype)initWithFilePath:(NSString *)filePath andFileName:(NSString *)fileName {
  if (self = [super init]) {
    _fileName = fileName;
    _filePath = filePath;
  }
  return self;
}
@end
