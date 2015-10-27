//
//  BlobJsonResponse.m
//  Instasite
//
//  Created by mike davis on 10/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "BlobJsonResponse.h"

@implementation BlobJsonResponse

- (instancetype)initFromJson:(NSDictionary *)jsonDict {
  self = [super init];
  if (self) {
    _sha = jsonDict[@"sha"];
    if (!_sha) {
      return nil;
    }
  }
  return self;
}
@end
