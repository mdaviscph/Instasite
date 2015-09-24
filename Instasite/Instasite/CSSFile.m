//
//  CSSFile.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CSSFile.h"

@implementation CSSFile
- (instancetype)initWithFilePath:(NSString *)filePath andFileName:(NSString *)fileName {
  if (self = [super init]) {
    _filePath = filePath;
    _fileName = fileName;
  }
  return self;
}
@end
