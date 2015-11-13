//
//  Label.m
//  Instasite
//
//  Created by mike davis on 11/13/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "Label.h"

@implementation Label

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  
  if ([self.delegate respondsToSelector:@selector(labelTouchBegin:)]) {
    [self.delegate labelTouchBegin:self];
  }
  [super touchesBegan:touches withEvent:event];
}

@end
