//
//  FileInfo.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface FileInfo : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *extension;
@property (nonatomic) FileType type;
@property (strong,nonatomic) NSString *path;
@property (strong,nonatomic) NSString *templateDirectory;
@property (strong,nonatomic) NSString *documentsDirectory;

- (instancetype)initWithFileName:(NSString *)name extension:(NSString *)extension type:(FileType)type relativePath:(NSString *)path templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory;

- (NSString *)filepathIncludingDocumentsDirectory;
- (NSString *)filepathFromTemplateDirectory;
- (NSString *)mimeTypeFromType;

- (NSString *)description;

@end
