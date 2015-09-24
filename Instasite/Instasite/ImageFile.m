//
//  ImageFile.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImageFile.h"

@implementation ImageFile
- (instancetype)init:(NSString *)filePath fileName:(NSString *)fileName {
  self.fileName = fileName;
  self.filePath = filePath;
  return self;
}
@end
