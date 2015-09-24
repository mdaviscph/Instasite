//
//  FileManager.h
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject <NSFileManagerDelegate>
- (void)listAllLocalFiles;
- (void)createFileWithName:(NSString *)fileName;
- (void)deleteFileWithName:(NSString *)fileName;
- (void)readFileWithName:(NSString *)fileName;
- (void)writeString:(NSString *)content toFile:(NSString *)fileName;
- (void) copyDirectory:(NSString *)directory;
@end
