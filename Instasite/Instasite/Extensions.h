//
//  Extensions.h
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "HtmlTemplate.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextField (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerType)type placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style;

@end

@interface UITextView (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerType)type placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style;

@end
