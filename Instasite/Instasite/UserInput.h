//
//  UserInput.h
//  Instasite
//
//  Created by mike davis on 10/31/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface UserInput : NSObject

@property (strong, nonatomic) InputGroupDictionary *groups;
@property (nonatomic) NSInteger maxGroupTag, maxCategoryTag, maxFieldTag;

- (NSData *)createJsonData;
- (void)updateUsingJsonData:(NSData *)data;

@end
