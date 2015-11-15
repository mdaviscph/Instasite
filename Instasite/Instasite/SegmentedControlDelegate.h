//
//  SegmentedControlDelegate.h
//  Instasite
//
//  Created by mike davis on 11/13/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentedControlDelegate <NSObject>

- (void)segmentedControlIndexWillChange:(UISegmentedControl *)sender;

@end