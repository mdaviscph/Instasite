//
//  Extensions.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "Extensions.h"

@implementation UITextField (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerTextEdit)type text:(NSString *)text placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style {
  self = [self init];
  if (self) {
    self.text = text;
    self.placeholder = placeholder;
    self.borderStyle = style;
    self.returnKeyType = UIReturnKeyDone;
    self.tag = type;
    [self setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:200 forAxis:UILayoutConstraintAxisVertical];
  }
  return self;
}

@end

@implementation UITextView (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerTextEdit)type text:(NSString *)text placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style {
  self = [self init];
  if (self) {
    [self setText:text orPlaceholder:placeholder];
    UIColor *borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
    if (style == UITextBorderStyleRoundedRect) {
      self.layer.borderColor = borderColor.CGColor;
      self.layer.borderWidth = 0.8;
      self.layer.cornerRadius = 5.0;
    }
    self.returnKeyType = UIReturnKeyDefault;
    self.tag = type;
    [self setContentHuggingPriority:200 forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:800 forAxis:UILayoutConstraintAxisVertical];
  }
  return self;
}

- (void)setText:(NSString *)text orPlaceholder:(NSString *)placeholder {
  UIColor *placeholderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
  self.textColor = text ? [UIColor blackColor] : placeholderColor;
  self.text = text ? text : placeholder;
}
- (void)clearPlaceholder {
  if (![self.textColor isEqual:[UIColor blackColor]]) {
    self.text = nil;
    self.textColor = [UIColor blackColor];
  }
}

@end

@implementation NSString (Extensions)

- (NSString *)abbreviate:(NSUInteger)anIndex {
  return self.length > anIndex ? [[self substringToIndex:anIndex] stringByAppendingString:@"..."] : self;
}

@end
