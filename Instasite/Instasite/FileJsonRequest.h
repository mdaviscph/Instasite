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
@property (strong, nonatomic) NSString *encoding;
@property (strong, nonatomic) NSString *content;

- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha mode:(NSString *)mode type:(NSString *)type encoding:(NSString *)encoding content:(NSString *)content;
- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha base64content:(NSString *)content;
- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha;

- (NSDictionary *)createJson;

@end
