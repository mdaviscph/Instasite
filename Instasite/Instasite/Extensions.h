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

- (instancetype)initWithMarkerType:(HtmlMarkerTextEdit)type text:(NSString *)text placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style;

@end

@interface UITextView (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerTextEdit)type text:(NSString *)text placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style;
- (void)setText:(NSString *)text orPlaceholder:(NSString *)placeholder;
- (void)clearPlaceholder;

@end

@interface UIButton (Extensions)

- (instancetype)initWithTitle:(NSString *)text;

@end

@interface NSString (Extensions)

- (NSString *)abbreviate:(NSUInteger)anIndex;

@end
