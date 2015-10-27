//
//  FileInfo.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface FileInfo : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *extension;
@property (nonatomic) FileType type;
@property (strong,nonatomic) NSString *path;
@property (strong,nonatomic) NSString *remoteDirectory;
@property (strong,nonatomic) NSString *localDirectory;

- (instancetype)initWithFileName:(NSString *)name extension:(NSString *)extension type:(FileType)type relativePath:(NSString *)path remoteDirectory:(NSString *)remoteDirectory localDirectory:(NSString *)localDirectory;

- (NSString *)filepathIncludingLocalDirectory;
- (NSString *)filepathFromRemoteDirectory;

- (NSString *)description;

@end
