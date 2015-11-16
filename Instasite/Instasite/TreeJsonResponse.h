//
//  TreeJsonResponse.h
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface TreeJsonResponse : NSObject

@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) FileJsonResponseArray *files;

- (instancetype)initFromJson:(NSDictionary *)jsonDict;

@end
