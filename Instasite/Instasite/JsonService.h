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
+ (BOOL)writeJsonFile:(NSData *)data fileURL:(NSURL *)fileURL;
+ (NSData *)readJsonFile:(NSURL *)fileURL;

@end
