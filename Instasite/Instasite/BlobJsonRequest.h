//
//  BlobJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileInfo;

@interface BlobJsonRequest : NSObject

@property (strong, nonatomic) FileInfo *file;

- (instancetype)initWithFileInfo:(FileInfo *)file;
- (NSDictionary *)createJson;

@end
