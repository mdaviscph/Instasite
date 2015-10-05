//
//  ImageCell.m
//  Instasite
//
//  Created by mike davis on 10/3/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()

@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)UIView *borderView;
@property (strong, nonatomic)UILabel *placeholderLabel;

@end

@implementation ImageCell

- (void)setPlaceholder:(NSString *)placeholder {
  _placeholder = placeholder;
  if (placeholder) {
    self.placeholderLabel.text = placeholder;
  } else {
    [self.placeholderLabel removeFromSuperview];
    self.placeholderLabel = nil;
  }
}

- (UILabel *)placeholderLabel {
  if (!_placeholderLabel) {
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.backgroundColor = [UIColor darkGrayColor];
    _placeholderLabel.textAlignment = NSTextAlignmentCenter;
    _placeholderLabel.textColor = [UIColor whiteColor];
    [self addViewWithConstraints:_placeholderLabel toSuperview:self.borderView withVerticalSpacing:2.0 withHorizontalSpacing:2.0];
  }
  return _placeholderLabel;
}

- (void)setImage:(UIImage *)image {
  _image = image;
  if (image) {
    self.imageView.image = image;
  } else {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
  }
  NSLog(@"image size: {%.2f,%.2f}", image.size.height, image.size.width);
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addViewWithConstraints:_imageView toSuperview:self.borderView withVerticalSpacing:2.0 withHorizontalSpacing:2.0];
  }
  return _imageView;
}
- (UIView *)borderView {
  if (!_borderView) {
    _borderView = [[UIView alloc] init];
    _borderView.backgroundColor = [UIColor darkGrayColor];
    [self addViewWithConstraints:_borderView toSuperview:self.contentView];
  }
  return _borderView;
}

- (void) addViewWithConstraints:(UIView *)view toSuperview:(UIView *)superview {
  
  [superview addSubview:view];
  [view setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSDictionary *viewsInfo = @{@"view" : view};
  [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0  metrics:nil views:viewsInfo]];
  [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0  metrics:nil views:viewsInfo]];
}

- (void)addViewWithConstraints:(UIView *)view toSuperview:(UIView *)superview withVerticalSpacing:(CGFloat)verticalSpacing withHorizontalSpacing:(CGFloat)horizontalSpacing {
  
  [superview addSubview:view];
  [view setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSDictionary *viewsInfo = @{@"view" : view};
  NSDictionary *metricsInfo = @{@"verticalSpacing" : @(verticalSpacing), @"horizontalSpacing" : @(horizontalSpacing)};
  [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalSpacing-[view]-verticalSpacing-|" options:0  metrics:metricsInfo views:viewsInfo]];
  [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalSpacing-[view]-horizontalSpacing-|" options:0  metrics:metricsInfo views:viewsInfo]];
}

@end
