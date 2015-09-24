//
//  ParseJSONService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ParseJSONService.h"

@implementation ParseJSONService

+ (void)getGithubUsernameFromJSON:(NSDictionary *)jsonData completionHandler:(void(^)(NSString *username))completionHandler {
  NSString *username = jsonData[@"login"];
  completionHandler(username,email);
}
@end
