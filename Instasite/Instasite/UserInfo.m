//
//  UserInfo.m
//  Instasite
//
//  Created by mike davis on 10/7/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "UserInfo.h"
#import "Constants.h"

@implementation UserInfo

- (instancetype)initFromJSON:(NSDictionary *)json {
  self = [super init];
  if (self) {
    _name = json[@"login"];
    _fullName = json[@"name"];
    _email = json[@"email"];
  }
  return self;
}

- (instancetype)initFromUserDefaults {
  self = [super init];
  if (self) {
    _email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmailKey];
    _fullName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFullNameKey];
    _name = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsNameKey];
    if (!_name) {
      return nil;
    }
  }
  return self;
}

- (void)saveToUserDefaults {
  if (self.name) {
    [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:kUserDefaultsEmailKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.fullName forKey:kUserDefaultsFullNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.name forKey:kUserDefaultsNameKey];
  }
}

@end
