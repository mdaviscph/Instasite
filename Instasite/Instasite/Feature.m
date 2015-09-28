//
//  Feature.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "Feature.h"
#import "Extensions.h"

@implementation Feature

- (NSString *)description {
  return [NSString stringWithFormat:@"(%@)(%@)(%@)[%@]", self.headline, self.subheadline, [self.body abbreviate:10], self.imageSrc];
}
          
@end
