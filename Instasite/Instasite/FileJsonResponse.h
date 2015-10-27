//
//  FileJsonResponse.h
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileJsonResponse : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) NSString *encoding;
@property (strong, nonatomic) NSString *content;

@end
