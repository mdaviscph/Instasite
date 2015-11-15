//
//  SegmentedControl.m
//  Instasite
//
//  Created by mike davis on 9/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "SegmentedControl.h"

@implementation SegmentedControl

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  
  if ([self.delegate respondsToSelector:@selector(segmentedControlIndexWillChange:)]) {
    [self.delegate segmentedControlIndexWillChange:self];
  }
  [super touchesBegan:touches withEvent:event];
}

- (void)resetWithTitles:(NSArray<NSString *> *)titles {
  [self removeAllSegments];
  for (NSUInteger index = 0; index < titles.count; index++) {
    [self insertSegmentWithTitle:titles[index] atIndex:index animated:YES];
  }
  [self setSelectedSegmentIndex:0];
}

@end
