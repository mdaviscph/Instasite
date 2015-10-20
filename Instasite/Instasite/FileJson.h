//
//  FileJson.h
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileJson : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *encoding;
@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) NSString *content;

- (instancetype)initWithPath:(NSString *)path mode:(NSString *)mode type:(NSString *)type encoding:(NSString *)encoding sha:(NSString *)sha content:(NSString *)content;
- (instancetype)initWithPath:(NSString *)path sha:(NSString *)sha content:(NSString *)content;
- (instancetype)initFromJSON:(NSDictionary *)json;

- (NSDictionary *)createJson;

@end
