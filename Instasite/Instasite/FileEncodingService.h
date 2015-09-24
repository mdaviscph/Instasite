//
//  FileEncodingService.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileEncodingService : NSObject
+ (NSString *)encodeImage:(NSString *)imagePath;
+ (NSString *)encodeHTML:(NSString *)filePath;
+ (NSString *)encodeCSS:(NSString *)cssPath;

@end
