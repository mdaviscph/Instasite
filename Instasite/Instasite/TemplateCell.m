//
//  TemplateCell.m
//  Instasite
//
//  Created by mike davis on 11/8/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateCell.h"
#import "TemplateView.h"

@interface TemplateCell ()

@property (strong, nonatomic)UIStackView *horizontalStackView;

@end

@implementation TemplateCell

- (void)setTemplates:(NSArray<TemplateView *> *)templates {
  _templates = templates;
  [self updateUI];
}

- (void)updateUI {
  
  if (self.horizontalStackView) {
    for (UIView *subview in self.horizontalStackView.arrangedSubviews) {
      [self.horizontalStackView removeArrangedSubview:subview];
      [subview removeFromSuperview];
    }
  } else {
    self.horizontalStackView = [[UIStackView alloc] init];
    self.horizontalStackView.axis = UILayoutConstraintAxisHorizontal;
    self.horizontalStackView.distribution = UIStackViewDistributionFillEqually;
    [self addViewWithConstraints:self.horizontalStackView toSuperview:self.contentView withVerticalSpacing:6.0 withHorizontalSpacing:6.0];
  }

  NSUInteger index = 0;
  for (TemplateView *template in self.templates) {
    UIStackView *verticalStackView = [[UIStackView alloc] init];
    verticalStackView.axis = UILayoutConstraintAxisVertical;
    verticalStackView.spacing = 8.0;
    verticalStackView.distribution = UIStackViewDistributionEqualSpacing;
    verticalStackView.alignment = UIStackViewAlignmentCenter;
    
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:template.image forState:UIControlStateNormal];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:100];
    widthConstraint.priority = UILayoutPriorityDefaultHigh;  // get "Unable to simultaneously satisfy constraints" without this
    widthConstraint.active = YES;
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:100];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    heightConstraint.active = YES;


    button.tag = index;
    [button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [verticalStackView addArrangedSubview:button];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = template.title;
    label.numberOfLines = 0;
    label.tag = index;

    [verticalStackView addArrangedSubview:label];
    
    [self.horizontalStackView addArrangedSubview:verticalStackView];
    index++;
  }
}

- (void)touchUpInside:(UIButton *)sender {
  if ([self.delegate respondsToSelector:@selector(templateCell:didSelectItemWithName:)]) {    
    [self.delegate templateCell:self didSelectItemWithName:self.templates[sender.tag].name];
  }
}

- (void)addViewWithConstraints:(UIView *)view toSuperview:(UIView *)superview {
  
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
