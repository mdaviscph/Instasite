//
//  JsonService.h
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TemplateInput;

@interface JsonService : NSObject

+ (NSData *)fromTemplateInput:(TemplateInput *)templateInput;
+ (TemplateInput *)templateInputFrom:(NSData *)data;
+ (BOOL)writeJsonFile:(NSData *)data filename:(NSString *)filename type:(NSString *)type directory:(NSString *)directory;
+ (NSData *)readJsonFile:(NSString *)filename type:(NSString *)type directory:(NSString *)directory;

@end
