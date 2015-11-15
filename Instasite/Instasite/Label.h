//
//  Label.h
//  Instasite
//
//  Created by mike davis on 11/13/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "LabelDelegate.h"
#import <UIKit/UIKit.h>

@interface Label : UILabel

@property (weak, nonatomic) id<LabelDelegate> delegate;

@end
