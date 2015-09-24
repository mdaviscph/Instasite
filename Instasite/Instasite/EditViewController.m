//
//  EditViewController.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewController.h"
#import "Extensions.h"
#import "HtmlTemplate.h"
#import "TemplateTabBarController.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *topStackView;
@property (weak, nonatomic) IBOutlet UIStackView *bottomStackView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *featureSegmentedControl;

@property (nonatomic) NSUInteger topStackSpacing;
@property (nonatomic) NSUInteger bottomStackSpacing;
@property (nonatomic) NSUInteger topTextViewHeight;
@property (nonatomic) NSUInteger bottomTextViewHeight;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) NSDictionary *markers;

@end

@implementation EditViewController

- (IBAction)publishButtonTapped:(UIButton *)sender {
}

- (IBAction)featureSegmentedControlTapped:(UISegmentedControl *)sender {
  for (UIView *subview in self.bottomStackView.arrangedSubviews) {
    [self.bottomStackView removeArrangedSubview:subview];
    [subview removeFromSuperview];
  }
  [self addFeatureControlsForFeature:sender.selectedSegmentIndex];
}

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = NO;

  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  self.markers = [self.tabBarVC.workingHtml templateMarkers];
  
  // turn off the fixed height constraint
  for (NSLayoutConstraint* constraint in self.topStackView.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeHeight) {
      constraint.active = NO;
    }
  }
  
  self.topStackSpacing = 6;
  self.topTextViewHeight = 60;

  self.bottomStackSpacing = 6;
  self.bottomTextViewHeight = 60;
  
  NSUInteger topStackHeight = 0;
  
  self.topStackView.axis = UILayoutConstraintAxisVertical;
  self.topStackView.spacing = self.topStackSpacing;
  self.bottomStackView.axis = UILayoutConstraintAxisVertical;
  self.bottomStackView.spacing = self.bottomStackSpacing;

  if (self.markers[kMarkerTitle]) {
    UITextField *titleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerTitle placeholder:@"Title text..." borderStyle:UITextBorderStyleRoundedRect];
    titleField.delegate = self;
    [self.topStackView addArrangedSubview:titleField];
    topStackHeight += titleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.markers[kMarkerSubtitle]) {
    UITextField *subtitleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubtitle placeholder:@"Subtitle text..." borderStyle:UITextBorderStyleRoundedRect];
    subtitleField.delegate = self;
    [self.topStackView addArrangedSubview:subtitleField];
    topStackHeight += subtitleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.markers[kMarkerSummary]) {
    UITextView *summaryTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerSummary placeholder:@"Summary text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:summaryTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.topTextViewHeight];
    constraint.active = YES;
    summaryTextView.delegate = self;
    [self.topStackView addArrangedSubview:summaryTextView];
    topStackHeight += self.topTextViewHeight + self.topStackSpacing;
  }
  if (self.markers[kMarkerCopyright]) {
    UITextField *copyrightField = [[UITextField alloc] initWithMarkerType:HtmlMarkerCopyright placeholder:@"Copyright text..." borderStyle:UITextBorderStyleRoundedRect];
    copyrightField.delegate = self;
    [self.topStackView addArrangedSubview:copyrightField];
    topStackHeight += copyrightField.intrinsicContentSize.height + self.topStackSpacing;
  }
  NSLayoutConstraint *topStackHeightConstraint = [NSLayoutConstraint constraintWithItem:self.topStackView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:topStackHeight];
  topStackHeightConstraint.active = YES;
  
  NSArray *features = self.markers[kFeatureArray];
  [self.featureSegmentedControl removeAllSegments];
  for (NSUInteger index = 0; index < features.count; index++) {
    NSDictionary *featureDict = features[index];
    if (featureDict.count > 0) {
      [self.featureSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"%lu", index] atIndex:index animated:YES];
    }
  }
  
  [self addFeatureControlsForFeature:0];
  self.featureSegmentedControl.selectedSegmentIndex = 0;
}

#pragma mark - Helper Methods
- (void)addFeatureControlsForFeature:(NSInteger)index {

  NSUInteger bottomStackHeight = 0;

  NSArray *features = self.markers[kFeatureArray];
  if (index < 0 || index >= features.count) {
    return;
  }
  
  NSDictionary *featureDict = features[index];
  if (featureDict[kMarkerHead]) {
    UITextField *headlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerHeadline placeholder:@"Headline text..." borderStyle:UITextBorderStyleRoundedRect];
    headlineField.delegate = self;
    [self.bottomStackView addArrangedSubview:headlineField];
    bottomStackHeight += headlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerSub]) {
    UITextField *subheadlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubheadline placeholder:@"Subheadline text..." borderStyle:UITextBorderStyleRoundedRect];
    subheadlineField.delegate = self;
    [self.bottomStackView addArrangedSubview:subheadlineField];
    bottomStackHeight += subheadlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerBody]) {
    UITextView *bodyTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerBody placeholder:@"Body text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:bodyTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.bottomTextViewHeight];
    constraint.active = YES;
    bodyTextView.delegate = self;
    [self.bottomStackView addArrangedSubview:bodyTextView];
    bottomStackHeight += self.bottomTextViewHeight + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerImageSrc]) {
    UIButton *imageSrcButton = [[UIButton alloc] initWithMarkerType:HtmlMarkerImageSrc text:@"Select Image"];
    [imageSrcButton addTarget:self action:@selector(selectImageButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [imageSrcButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [self.bottomStackView addArrangedSubview:imageSrcButton];
    bottomStackHeight += imageSrcButton.frame.size.height + self.bottomStackSpacing;
  }
}

- (void)nslogMarkerDictionary {
  for (NSString *key in [self.markers allKeys]) {
    if ([key isEqualToString:kFeatureArray]) {
      NSArray *features = self.markers[key];
      NSInteger number = 1;
      for (NSDictionary *featureDict in features) {
        if (featureDict.count > 0) {
          for (NSString *featureKey in featureDict) {
            NSLog(@"feature: %ld key: %@ count: %ld", number, featureKey, [(NSNumber *)featureDict[featureKey] integerValue]);
          }
        } else {
          NSLog(@"feature: %ld is empty", number);
        }
        number++;
      }
    } else {
      NSLog(@"key: %@ count: %ld", key, [(NSNumber *)self.markers[key] integerValue]);
    }
  }
}

#pragma mark - Selector Methods
- (void)selectImageButtonUp:(UIButton *)sender {
  
  switch (sender.tag) {
    case HtmlMarkerImageSrc:
      NSLog(@"image src button pressed");
      break;
      
    default:
      break;
  }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  switch (textField.tag) {
    case HtmlMarkerTitle:
      NSLog(@"title %@", textField.text);
      break;
    case HtmlMarkerSubtitle:
      NSLog(@"subtitle %@", textField.text);
      break;
    case HtmlMarkerHeadline:
      NSLog(@"headline %@", textField.text);
      break;
    case HtmlMarkerSubheadline:
      NSLog(@"subheadline %@", textField.text);
      break;
    case HtmlMarkerCopyright:
      NSLog(@"copyright %@", textField.text);
      break;
      
    default:
      break;
  }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {

  switch (textView.tag) {
    case HtmlMarkerSummary:
      NSLog(@"summary %@", textView.text);
      break;
    case HtmlMarkerBody:
      NSLog(@"body %@", textView.text);
      break;
      
    default:
      break;
  }
}

@end


