//
//  FileEncodingService.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface FileEncodingService : NSObject

+ (NSString *)encodeFile:(NSString *)filePath withType:(FileType)type;

@end
