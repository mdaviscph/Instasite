//
//  TemplateInput.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateInput.h"
#import "Feature.h"

@implementation TemplateInput

- (instancetype)initWithFeatures:(NSUInteger)count {
  self = [super init];
  if (self) {
    NSMutableArray *mutableFeatures = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < count; index++) {
      [mutableFeatures addObject:[[Feature alloc] init]];
    }
    self.features = mutableFeatures;
  }
  return self;
}

@end
