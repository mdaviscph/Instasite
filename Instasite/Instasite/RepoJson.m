//
//  RepoJson.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoJson.h"

@implementation RepoJson

- (instancetype)initFromJSON:(NSDictionary *)json;
{
  self = [super init];
  if (self) {
    _name = json[@"name"];
    _fullName = json[@"full_name"];
    _aDescription = json[@"description"];
    _htmlURL = json[@"html_url"];
  }
  return self;
}

@end
