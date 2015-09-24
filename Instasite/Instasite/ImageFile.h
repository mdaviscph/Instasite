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
- (instancetype)initWithFilePath:(NSString *)filePath andFileName:(NSString *)fileName;

@end
