//
//  ImageFile.h
//  Instasite
//
//  Created by Sam Wilskey on 9/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageFile : NSObject
@property (strong,nonatomic) NSString *fileName;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSString *documentsDirectory;

- (instancetype)initWithPath:(NSString *)path andFileName:(NSString *)fileName andDocumentsDirectory:(NSString *)directory;
- (NSString *)description;
@end
