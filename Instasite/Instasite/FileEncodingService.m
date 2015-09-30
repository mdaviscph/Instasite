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
  if (!image) {
    NSLog(@"Error! imageWithContentsOfFile: [%@]", imagePath);
  }
  return [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

+ (NSString *)encodeHTML:(NSString *)filePath {

  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", filePath, error.localizedDescription);
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}

+(NSString *)encodeCSS:(NSString *)cssPath{
  
  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:cssPath options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", cssPath, error.localizedDescription);
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}

+(NSString *)encodeJSON:(NSString *)JSONPath{
  
  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:JSONPath options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", JSONPath, error.localizedDescription);
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}

@end
