//
//  EditViewController.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewController.h"
#import "EditViewControllerImagePickerExtension.h"
#import "Extensions.h"
#import "HtmlTemplate.h"
#import "TemplateInput.h"
#import "Feature.h"
#import "JsonService.h"
#import "Constants.h"
#import "TemplateTabBarController.h"
#import "PublishViewController.h"
#import <SSKeychain/SSKeychain.h>
#import "FileManager.h"
#import "CSSFile.h"
#import "ImageFile.h"
#import "SegmentedControl.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate, SegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *topStackView;
@property (weak, nonatomic) IBOutlet UIStackView *bottomStackView;
@property (weak, nonatomic) IBOutlet SegmentedControl *featureSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topStackViewHeightConstraint;

@property (nonatomic) NSUInteger topStackSpacing;
@property (nonatomic) NSUInteger bottomStackSpacing;
@property (nonatomic) NSUInteger topTextViewHeight;
@property (nonatomic) NSUInteger bottomTextViewHeight;
@property (nonatomic) UIView *lastTextEditingView;

@property (strong, nonatomic) NSDictionary *markers;

@end

@implementation EditViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];

  self.markers = [self.tabBarVC.workingHtml templateMarkers];
  NSArray *features = self.markers[kFeatureArray];

  [self.featureSegmentedControl removeAllSegments];
  for (NSUInteger index = 0; index < features.count; index++) {
    NSDictionary *featureDict = features[index];
    if (featureDict.count > 0) {
      [self.featureSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"Feature %lu", index+1] atIndex:index animated:YES];
    }
  }

  NSData *jsonData = [JsonService readJsonFile:kTemplateJsonFilename type:kTemplateJsonFiletype directory:self.tabBarVC.templateDirectory];
  if (jsonData) {
    self.userInput = [JsonService templateInputFrom:jsonData];
  } else {
    self.userInput = [[TemplateInput alloc] initWithFeatures:features.count];
  }

  self.topStackSpacing = 6;
  self.topTextViewHeight = 60;
  self.bottomStackSpacing = 6;
  self.bottomTextViewHeight = 60;
  
  NSUInteger topStackHeight = 0;
  self.topStackViewHeightConstraint.active = NO;
  
  self.topStackView.axis = UILayoutConstraintAxisVertical;
  self.topStackView.spacing = self.topStackSpacing;
  self.bottomStackView.axis = UILayoutConstraintAxisVertical;
  self.bottomStackView.spacing = self.bottomStackSpacing;

  if (self.markers[kMarkerTitle]) {
    UITextField *titleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerTitle placeholder:@"Title text..." borderStyle:UITextBorderStyleRoundedRect];
    titleField.delegate = self;
    if (self.userInput.title) {
      titleField.text = self.userInput.title;
    }
    
    [self.topStackView addArrangedSubview:titleField];
    topStackHeight += titleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.markers[kMarkerSubtitle]) {
    UITextField *subtitleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubtitle placeholder:@"Subtitle text..." borderStyle:UITextBorderStyleRoundedRect];
    subtitleField.delegate = self;
    if (self.userInput.subtitle) {
      subtitleField.text = self.userInput.subtitle;
    }
    
    [self.topStackView addArrangedSubview:subtitleField];
    topStackHeight += subtitleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.markers[kMarkerSummary]) {
    UITextView *summaryTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerSummary placeholder:@"Summary text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:summaryTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.topTextViewHeight];
    constraint.active = YES;
    summaryTextView.delegate = self;
    if (self.userInput.summary) {
      summaryTextView.text = self.userInput.summary;
    }
    
    [self.topStackView addArrangedSubview:summaryTextView];
    topStackHeight += self.topTextViewHeight + self.topStackSpacing;
  }
  if (self.markers[kMarkerCopyright]) {
    UITextField *copyrightField = [[UITextField alloc] initWithMarkerType:HtmlMarkerCopyright placeholder:@"Copyright text..." borderStyle:UITextBorderStyleRoundedRect];
    copyrightField.delegate = self;
    if (self.userInput.copyright) {
      copyrightField.text = self.userInput.copyright;
    }
    
    [self.topStackView addArrangedSubview:copyrightField];
    topStackHeight += copyrightField.intrinsicContentSize.height + self.topStackSpacing;
  }
  NSLayoutConstraint *topStackHeightConstraint = [NSLayoutConstraint constraintWithItem:self.topStackView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:topStackHeight];
  topStackHeightConstraint.active = YES;

  self.featureSegmentedControl.delegate = self;
  self.selectedFeature = 0;
  self.featureSegmentedControl.selectedSegmentIndex = self.selectedFeature;
  [self addFeatureControlsForFeature:self.selectedFeature];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
  [self startObservingKeyboardEvents];
}

-(void)viewWillDisappear:(BOOL)animated {
  [self writeWorkingFile:kTemplateIndexFilename ofType:kTemplateIndexFiletype];
  [self stopObservingKeyboardEvents];
  [super viewWillDisappear:animated];
}

#pragma mark - Helper Methods

- (void)addFeatureControlsForFeature:(NSInteger)index {

  NSUInteger bottomStackHeight = 0;

  NSArray *features = self.markers[kFeatureArray];
  if (index < 0 || index >= features.count) {
    return;
  }
  Feature *feature = self.userInput.features[index];
  
  NSDictionary *featureDict = features[index];
  if (featureDict[kMarkerHead]) {
    UITextField *headlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerHeadline placeholder:@"Headline text..." borderStyle:UITextBorderStyleRoundedRect];
    headlineField.delegate = self;
    if (feature.headline) {
      headlineField.text = feature.headline;
    }

    [self.bottomStackView addArrangedSubview:headlineField];
    bottomStackHeight += headlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerSub]) {
    UITextField *subheadlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubheadline placeholder:@"Subheadline text..." borderStyle:UITextBorderStyleRoundedRect];
    subheadlineField.delegate = self;
    if (feature.subheadline) {
      subheadlineField.text = feature.subheadline;
    }
    
    [self.bottomStackView addArrangedSubview:subheadlineField];
    bottomStackHeight += subheadlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerBody]) {
    UITextView *bodyTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerBody placeholder:@"Body text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:bodyTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.bottomTextViewHeight];
    constraint.active = YES;
    bodyTextView.delegate = self;
    if (feature.body) {
      [bodyTextView clearPlaceholder];
      bodyTextView.text = feature.body;
    }
    
    [self.bottomStackView addArrangedSubview:bodyTextView];
    bottomStackHeight += self.bottomTextViewHeight + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerImageSrc]) {
    UIButton *imageSrcButton = [[UIButton alloc] initWithTitle:@"Select Image"];
    [imageSrcButton addTarget:self action:@selector(selectImageButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [imageSrcButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [self.bottomStackView addArrangedSubview:imageSrcButton];
    bottomStackHeight += imageSrcButton.frame.size.height + self.bottomStackSpacing;
  }
}

- (BOOL)writeWorkingFile:(NSString *)filename ofType:(NSString *)type {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  if ([self.tabBarVC.workingHtml writeToFile:filename ofType:type inDirectory:self.tabBarVC.templateDirectory]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, type, self.tabBarVC.templateDirectory);
  return NO;
}

- (void)advanceNextResponder:(UIView *)textEditingView {

  NSInteger tag = textEditingView.tag;
  UIView *parentView = self.topStackView;
  UIResponder* nextResponder;
  do {
    if (tag >= HtmlMarkerTextEditStartOfFeature) {
      parentView = self.bottomStackView;
    }
    nextResponder = [parentView viewWithTag:++tag];
  } while (!nextResponder && tag < HtmlMarkerTextEditEndOfFeature);
  if (nextResponder) {
    [nextResponder becomeFirstResponder];
  } else {
    [textEditingView resignFirstResponder];
  }
}

- (void)startObservingKeyboardEvents {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)stopObservingKeyboardEvents {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

#pragma mark - IBActions, Selector Methods

- (IBAction)featureSegmentedControlChange:(UISegmentedControl *)sender {
  
  self.selectedFeature = sender.selectedSegmentIndex;
  for (UIView *subview in self.bottomStackView.arrangedSubviews) {
    [self.bottomStackView removeArrangedSubview:subview];
    [subview removeFromSuperview];
  }
  [self addFeatureControlsForFeature:sender.selectedSegmentIndex];
}

- (void)saveButtonTapped {
  
  NSData *jsonData = [JsonService fromTemplateInput:self.userInput];
  [JsonService writeJsonFile:jsonData filename:kTemplateJsonFilename type:kTemplateJsonFiletype directory:self.tabBarVC.templateDirectory];
  
  [self writeWorkingFile:kTemplateIndexFilename ofType:kTemplateIndexFiletype];
  
  if (![SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    UIViewController *oauthVC = [oauthStoryboard instantiateInitialViewController];
    [self.navigationController pushViewController:oauthVC animated:YES];
  }
  if ([SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount]) {
    UIStoryboard *publishStoryboard = [UIStoryboard storyboardWithName:@"Publish" bundle:[NSBundle mainBundle]];
    PublishViewController *publishVC = [publishStoryboard instantiateInitialViewController];
    
    FileManager *fm = [[FileManager alloc]init];
    NSArray *files = [fm enumerateFilesInDirectory:self.tabBarVC.templateDirectory];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *workingDirectory = [documentsPath stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
    
    publishVC.indexHtmlFilePath = workingDirectory;
    publishVC.JSONfilePath = workingDirectory;
    for (CSSFile *file in files[0]) {
      NSLog(@"CSS: [%@] {%@}", file.filePath, file.fileName);
    }
    for (ImageFile *file in files[1]) {
      NSLog(@"IMAGE: [%@] {%@}", file.filePath, file.fileName);
    }
    publishVC.supportingFilePaths = files[0];
    publishVC.imageFilePaths = files[1];
    [self.navigationController pushViewController:publishVC animated:YES];
  }
}

- (void)selectImageButtonUp:(UIButton *)sender {  
  [self actionSheetForImageSelection:sender];
}

- (void)doneButtonTapped {
  [self advanceNextResponder:self.lastTextEditingView];
  //[self.lastTextEditingView endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
  
  NSDictionary *userInfo = notification.userInfo;
  CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  rect = [self.view convertRect:rect fromView:nil];
  self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, rect.size.height, 0.0);
}
- (void)keyboardWillHide:(NSNotification *)notification {
  self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  self.lastTextEditingView = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self advanceNextResponder:textField];
  return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  switch (textField.tag) {
    case HtmlMarkerTitle:
      [self.tabBarVC.workingHtml insertTitle:textField.text];
      self.userInput.title = textField.text;
      break;
    case HtmlMarkerSubtitle:
      [self.tabBarVC.workingHtml insertSubtitle:textField.text];
      self.userInput.subtitle = textField.text;
      break;
    case HtmlMarkerHeadline:
    {
      [self.tabBarVC.workingHtml insertFeature: self.selectedFeature headline:textField.text];
      Feature *feature = self.userInput.features[self.selectedFeature];
      feature.headline = textField.text;
      break;
    }
    case HtmlMarkerSubheadline:
    {
      [self.tabBarVC.workingHtml insertFeature: self.selectedFeature subheadline:textField.text];
      Feature *feature = self.userInput.features[self.selectedFeature];
      feature.subheadline = textField.text;
      break;
    }
    case HtmlMarkerCopyright:
      [self.tabBarVC.workingHtml insertCopyright:textField.text];
      self.userInput.copyright = textField.text;
      break;
  }
}


#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {

  [textView clearPlaceholder];
  self.lastTextEditingView = textView;
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
}

- (void)textViewDidEndEditing:(UITextView *)textView {

  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];

  switch (textView.tag) {
    case HtmlMarkerSummary:
      [self.tabBarVC.workingHtml insertSummary:textView.text];
      break;
    case HtmlMarkerBody:
    {
      [self.tabBarVC.workingHtml insertFeature: self.selectedFeature body:textView.text];
      Feature *feature = self.userInput.features[self.selectedFeature];
      feature.body = textView.text;
      break;
    }
  }
}

#pragma mark - SegmentedControlDelegate

// this protocol is defined in SegmentedControl.h and used so we can force editing to
// end, prior to the segnmentedControl index changing, for any textViews since there is
// no textViewShouldReturn delegate method
- (void)segmentedControlIndexWillChange:(UISegmentedControl *)sender {
  [self doneButtonTapped];
}

@end


