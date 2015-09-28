//
//  FileManager.h
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject <NSFileManagerDelegate>

- (NSArray *)enumerateFilesInDirectory:(NSString *)directory;
- (BOOL)copyDirectory:(NSString *)directory overwrite:(BOOL)overwrite;

@end
