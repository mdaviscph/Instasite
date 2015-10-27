//
//  TreeJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface TreeJsonRequest : NSObject

@property (strong, nonatomic) FileJsonRequestArray *files;

- (instancetype)initWithFileList:(FileJsonRequestArray *)files;
- (NSDictionary *)createJson;

@end
