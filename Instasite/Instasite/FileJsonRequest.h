//
//  FileJsonRequest.h
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileJsonRequest : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *type;

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha;

- (NSDictionary *)createJson;

@end
