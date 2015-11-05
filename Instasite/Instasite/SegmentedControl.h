//
//  SegmentedControl.h
//  Instasite
//
//  Created by mike davis on 9/26/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedControl : UISegmentedControl

@property (weak, nonatomic) id delegate;

- (void)resetWithTitles:(NSArray<NSString *> *)titles;

@end

@protocol SegmentedControlDelegate <NSObject>

- (void)segmentedControlIndexWillChange:(UISegmentedControl *)sender;

@end
