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

+ (NSString *)encodeFile:(NSString *)filePath withType:(FileType)type {
  
  NSData *data;
  if (type & FileTypeJpeg) {
    // must read as NSData since write is as NSData
    NSError *error;
    NSData *imageData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    if (error) {
      NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", filePath, error.localizedDescription);
      return nil;
    }
    UIImage *image = [UIImage imageWithData:imageData];
    if (!image) {
      NSLog(@"Error! UIImage:imageWithData: [%@]", filePath);
      return nil;
    }
    // TODO - determine if we need to compress the data due to large size
    data = UIImageJPEGRepresentation(image, 1.0);
    if (!data) {
      NSLog(@"Error! UIImageJPEGRepresentation: [%@]", filePath);
      return nil;
    }
  } else {
    NSError *error;
    data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    if (error) {
      NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", filePath, error.localizedDescription);
      return nil;
    }
  }
  NSString *baseString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
  if (!baseString) {
    NSLog(@"Error! NSData:base64EncodedStringWithOptions: [%@]", filePath);
    return nil;
  }
  return baseString;
}

@end
