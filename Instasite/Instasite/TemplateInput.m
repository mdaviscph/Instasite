//
//  TemplateInput.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateInput.h"
#import "Feature.h"
#import "Extensions.h"

@implementation TemplateInput

- (instancetype)initWithFeatures:(NSUInteger)count {
  self = [super init];
  if (self) {
    NSMutableArray *mutableFeatures = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < count; index++) {
      [mutableFeatures addObject:[[Feature alloc] init]];
    }
    _features = mutableFeatures;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%@)(%@)(%@)(%@)(%lu features)", self.title, self.subtitle, [self.summary abbreviate:10], self.copyright, self.features.count];
}
@end
