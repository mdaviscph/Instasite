//
//  FileJsonResponse.h
//  Instasite
//
//  Created by mike davis on 10/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileJsonResponse : NSObject

- (instancetype)initFromJson:(NSDictionary *)json;

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *type;

@end
