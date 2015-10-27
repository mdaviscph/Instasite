//
//  UserJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/7/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "UserJsonResponse.h"
#import "Constants.h"

@implementation UserJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _name = json[@"login"];
    _fullName = json[@"name"];
    _email = json[@"email"];
  }
  return self;
}

@end
