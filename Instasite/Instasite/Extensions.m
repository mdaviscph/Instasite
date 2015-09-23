//
//  Extensions.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "Extensions.h"

@implementation UITextField (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerType)type placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style {
  self = [self init];
  if (self) {
    self.placeholder = placeholder;
    self.borderStyle = style;
    self.tag = type;
  }
  return self;
}

@end

@implementation UITextView (Extensions)

- (instancetype)initWithMarkerType:(HtmlMarkerType)type placeholder:(NSString *)placeholder borderStyle:(UITextBorderStyle)style {
  self = [self init];
  if (self) {
    //self.attributedText = [AttributedText placeholder:placeholder];
    if (style == UITextBorderStyleRoundedRect) {
      self.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7].CGColor;
      self.layer.borderWidth = 0.8;
      self.layer.cornerRadius = 5.0;
    }
  }
  return self;
}

@end
