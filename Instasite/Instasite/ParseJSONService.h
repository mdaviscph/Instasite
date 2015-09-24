//
//  ParseJSONService.h
//  Instasite
//
//  Created by Sam Wilskey on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseJSONService : NSObject

+ (void)getGithubUsernameFromJSON:(NSDictionary *)jsonData completionHandler:(void(^)(NSString *username, NSString *email))completionHandler;

@end
