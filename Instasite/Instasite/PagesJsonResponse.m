//
//  PagesJsonResponse.m
//  Instasite
//
//  Created by mike davis on 11/16/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PagesJsonResponse.h"

@implementation PagesJsonResponse

- (instancetype)initFromJson:(NSDictionary *)json {
  self = [super init];
  if (self) {
    NSString *state = json[@"status"];
    if ([state isEqualToString:@"building"]) {
      _status = GitHubPagesInProgress;
    } else if ([state isEqualToString:@"built"]) {
      _status = GitHubPagesBuilt;
    } else if ([state isEqualToString:@"errored"]) {
      _status = GitHubPagesError;
    } else {
      _status = GitHubPagesNone;
    }
  }
  return self;
}

- (instancetype)initWithStatus:(GitHubPagesStatus)status {
  self = [super init];
  if (self) {
    _status = status;
  }
  return self;
}

@end
