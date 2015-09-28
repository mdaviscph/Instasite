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
  
  [self.delegate segmentedControlIndexWillChange:self];
  [super touchesBegan:touches withEvent:event];
}

@end
