//
//  RepoCell.m
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "RepoCell.h"
#import "Repo.h"

@interface RepoCell ()

@property (strong, nonatomic)UIView *borderView;
@property (strong, nonatomic)UILabel *nameLabel;
@property (strong, nonatomic)UILabel *descriptionLabel;
@property (strong, nonatomic)UILabel *updatedAtLabel;
@property (strong, nonatomic)UIStackView *stackView;

@end

@implementation RepoCell

- (void)setRepo:(Repo *)repo {
  _repo = repo;
  self.nameLabel.text = repo.name;
  self.descriptionLabel.text = repo.aDescription;
  self.updatedAtLabel.text = [self dateString:repo.updatedAt];
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor whiteColor];
    _nameLabel.numberOfLines = 0;
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.stackView addArrangedSubview:_nameLabel];
  }
  return _nameLabel;
}
- (UILabel *)descriptionLabel {
  if (!_descriptionLabel) {
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.backgroundColor = [UIColor whiteColor];
    _descriptionLabel.numberOfLines = 0;
    _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.stackView addArrangedSubview:_descriptionLabel];
  }
  return _descriptionLabel;
}
- (UILabel *)updatedAtLabel {
  if (!_updatedAtLabel) {
    _updatedAtLabel = [[UILabel alloc] init];
    _updatedAtLabel.backgroundColor = [UIColor whiteColor];
    _updatedAtLabel.numberOfLines = 0;
    _updatedAtLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [self.stackView addArrangedSubview:_updatedAtLabel];
  }
  return _updatedAtLabel;
}

- (UIStackView *)stackView {
  if (!_stackView) {
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 6.0;
    [self addViewWithConstraints:_stackView toSuperview:self.borderView withVerticalSpacing:3.0 withHorizontalSpacing:5.0];
  }
  return _stackView;
}
- (UIView *)borderView {
  if (!_borderView) {
    _borderView = [[UIView alloc] init];
    _borderView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    [self addViewWithConstraints:_borderView toSuperview:self.contentView withVerticalSpacing:2.0 withHorizontalSpacing:2.0];
  }
  return _borderView;
}

- (NSString *)dateString:(NSDate *)date {
  
  NSTimeInterval interval = -[date timeIntervalSinceNow];
  NSInteger minutes = (NSInteger)interval/60;
  NSInteger hours = (NSInteger)interval/3600;
  NSInteger days = (NSInteger)interval/86400;
  
  if (days > 30) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd yyyy";
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    return [NSString stringWithFormat:@"Updated on %@", [dateFormatter stringFromDate:date]];
  } else if (days > 1) {
    return [NSString stringWithFormat:@"Updated %ld days ago", (long)days];
  } else if (hours > 1) {
    return [NSString stringWithFormat:@"Updated %ld hours ago", (long)hours];
  } else {
    return [NSString stringWithFormat:@"Updated %ld minutes ago", (long)minutes];
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
