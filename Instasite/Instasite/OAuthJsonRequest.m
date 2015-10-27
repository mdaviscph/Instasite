//
//  OAuthJsonRequest.m
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "OAuthJsonRequest.h"

@implementation OAuthJsonRequest

- (instancetype)initWithCode:(NSString *)code clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
  self = [super init];
  if (self) {
    _code = code;
    _clientId = clientId;
    _clientSecret = clientSecret;
  }
  return self;
}

- (NSDictionary *)createJson {
  
  NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
  jsonDict[@"code"] = self.code;
  jsonDict[@"client_id"] = self.clientId;
  jsonDict[@"client_secret"] = self.clientSecret;
  
  return jsonDict;
}

@end
