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
@property (strong, nonatomic) FileJsonResponseArray *existingFiles;

- (instancetype)initWithFileList:(FileJsonRequestArray *)files existingFileList:(FileJsonResponseArray *)existingFiles;

- (NSDictionary *)createJson;

@end
