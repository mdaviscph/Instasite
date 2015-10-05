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

- (instancetype)initWithFeatureCount:(NSUInteger)featureCount imageCount:(NSUInteger)imageCount {
  self = [super init];
  if (self) {
    NSMutableArray *mutableFeatures = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < featureCount; index++) {
      [mutableFeatures addObject:[[Feature alloc] init]];
    }
    _features = mutableFeatures;
    NSMutableArray *mutableImageRefs = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < imageCount; index++) {
      [mutableImageRefs addObject:[[NSString alloc] init]];
    }
    _imageRefs = mutableImageRefs;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"(%@)(%@)(%@)(%@)(%lu features)(%lu images)", self.title, self.subtitle, [self.summary abbreviate:10], self.copyright, self.features.count, self.imageRefs.count];
}
@end
