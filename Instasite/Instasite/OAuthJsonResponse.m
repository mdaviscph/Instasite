//
//  OAuthJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "OAuthJsonResponse.h"

@implementation OAuthJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _accessToken = json[@"access_token"];
    if (!_accessToken) {
      return nil;
    }
    _scope = json[@"scope"];
  }
  return self;
}

@end
