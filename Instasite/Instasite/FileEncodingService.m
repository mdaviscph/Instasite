//
//  FileEncodingService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "FileEncodingService.h"
#import <UIKit/UIKit.h>

@implementation FileEncodingService

+ (NSString *)encodeImage:(NSString *)imagePath {
  UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
  return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (NSString *)encodeHTML:(NSString *)filePath {
  NSString *htmlString = [[NSString alloc] initWithContentsOfFile:filePath encoding:0 error:nil];
  
  NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}
@end
