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

  // must read as NSData since write is as NSData
  NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
  if (!imageData) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@]", imagePath);
    return nil;
  }
  UIImage *image = [UIImage imageWithData:imageData];
  if (!image) {
    NSLog(@"Error! UIImage:imageWithData: [%@]", imagePath);
    return nil;
  }
  // TODO - determine if we need to compress the data due to large size
  NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
  if (!jpegData) {
    NSLog(@"Error! UIImageJPEGRepresentation: [%@]", imagePath);
    return nil;
  }
  NSString *encodedImage = [jpegData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  if (!encodedImage) {
    NSLog(@"Error! UIImage:imageWithData: [%@]", imagePath);
    return nil;
  }
  return encodedImage;
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

+ (NSString *)encodeSupportingFile:(NSString *)filePath {
  
  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", filePath, error.localizedDescription);
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}

+ (NSString *)encodeJSON:(NSString *)JSONPath{
  
  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:JSONPath options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", JSONPath, error.localizedDescription);
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  return baseString;
}

@end
