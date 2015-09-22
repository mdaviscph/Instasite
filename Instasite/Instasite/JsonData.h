//
//  JsonData.h
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TemplateData;

@interface JsonData : NSObject

+ (NSData *)fromTemplateData:(TemplateData *)templateData;
+ (TemplateData *)templateDataFrom:(NSData *)data;

@end
