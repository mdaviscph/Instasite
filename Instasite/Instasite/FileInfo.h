//
//  FileInfo.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *path;
@property (strong,nonatomic) NSString *templateDirectory;
@property (strong,nonatomic) NSString *documentsDirectory;

- (instancetype)initWithFileName:(NSString *)name fileType:(NSString *)type relativePath:(NSString *)path templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory;

- (NSString *)filepathIncludingDocumentsDirectory;
- (NSString *)filepathFromTemplateDirectory;

- (NSString *)description;

@end
