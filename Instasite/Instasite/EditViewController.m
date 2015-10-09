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
#import "TemplateInput.h"
#import "Feature.h"
#import "JsonService.h"
#import "Constants.h"
#import "TemplateTabBarController.h"
#import "PublishViewController.h"
#import <SSKeychain/SSKeychain.h>
#import "FileManager.h"
#import "SegmentedControl.h"
#import "DisplayTemplateViewController.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate, SegmentedControlDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *topStackView;
@property (weak, nonatomic) IBOutlet UIStackView *bottomStackView;
@property (weak, nonatomic) IBOutlet SegmentedControl *featureSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topStackViewHeightConstraint;

@property (strong, nonatomic) NSArray *featureMarkers;
@property (strong, nonatomic) NSArray *imageRefMarkers;

@property (nonatomic) NSUInteger topStackSpacing;
@property (nonatomic) NSUInteger bottomStackSpacing;
@property (nonatomic) NSUInteger topTextViewHeight;
@property (nonatomic) NSUInteger bottomTextViewHeight;
@property (nonatomic) NSUInteger imageButtonHeight;
@property (nonatomic) UIView *lastTextEditingView;

@end

@implementation EditViewController

- (NSArray *)featureMarkers {
  if (!_featureMarkers) {
    _featureMarkers = self.tabBarVC.templateMarkers[kFeatureArray];
  }
  return _featureMarkers;
}
- (NSArray *)imageRefMarkers {
  if (!_imageRefMarkers) {
    _imageRefMarkers = self.tabBarVC.templateMarkers[kImageRefArray];
  }
  return _imageRefMarkers;
}

- (void)setLastTextEditingView:(UIView *)lastTextEditingView {
  [_lastTextEditingView endEditing:YES];
  _lastTextEditingView = lastTextEditingView;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  self.tabBarVC.delegate = self;

  [self.featureSegmentedControl removeAllSegments];
  for (NSUInteger index = 0; index < self.featureMarkers.count; index++) {
    [self.featureSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:@"Feature %lu", index+1] atIndex:index animated:YES];
  }

  NSData *jsonData = [JsonService readJsonFile:self.tabBarVC.userJsonURL];
  if (jsonData) {
    self.userInput = [JsonService templateInputFrom:jsonData];
    [self insertUserInputIntoTemplateCopy];
  } else {
    self.userInput = [[TemplateInput alloc] initWithFeatureCount:self.featureMarkers.count imageCount:self.imageRefMarkers.count];
  }

  self.topStackSpacing = 6;
  self.topTextViewHeight = 60;
  self.bottomStackSpacing = 6;
  self.bottomTextViewHeight = 60;
  self.imageButtonHeight = 80;
  
  NSUInteger topStackHeight = 0;
  self.topStackViewHeightConstraint.active = NO;
  
  self.topStackView.axis = UILayoutConstraintAxisVertical;
  self.topStackView.spacing = self.topStackSpacing;
  self.bottomStackView.axis = UILayoutConstraintAxisVertical;
  self.bottomStackView.spacing = self.bottomStackSpacing;

  if (self.tabBarVC.templateMarkers[kMarkerTitle]) {
    UITextField *titleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerTitle text:self.userInput.title placeholder:@"Title text..." borderStyle:UITextBorderStyleRoundedRect];
    titleField.delegate = self;
    [self.topStackView addArrangedSubview:titleField];
    topStackHeight += titleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.tabBarVC.templateMarkers[kMarkerSubtitle]) {
    UITextField *subtitleField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubtitle text:self.userInput.subtitle placeholder:@"Subtitle text..." borderStyle:UITextBorderStyleRoundedRect];
    subtitleField.delegate = self;
    [self.topStackView addArrangedSubview:subtitleField];
    topStackHeight += subtitleField.intrinsicContentSize.height + self.topStackSpacing;
  }
  if (self.tabBarVC.templateMarkers[kMarkerSummary]) {
    UITextView *summaryTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerSummary text:self.userInput.summary placeholder:@"Summary text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:summaryTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.topTextViewHeight];
    constraint.active = YES;
    summaryTextView.delegate = self;
    [self.topStackView addArrangedSubview:summaryTextView];
    topStackHeight += self.topTextViewHeight + self.topStackSpacing;
  }
  if (self.tabBarVC.templateMarkers[kMarkerCopyright]) {
    UITextField *copyrightField = [[UITextField alloc] initWithMarkerType:HtmlMarkerCopyright text:self.userInput.copyright placeholder:@"Copyright text..." borderStyle:UITextBorderStyleRoundedRect];
    copyrightField.delegate = self;
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
  self.tabBarVC.navigationItem.title = self.tabBarVC.repoName;
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];
  
  [self.tabBarVC.templateCopy resetToOriginal];
  [self assignImageRefsToUserInput];
  [self insertUserInputIntoTemplateCopy];
  
  [self startObservingKeyboardEvents];
}

-(void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self stopObservingKeyboardEvents];
}

#pragma mark - Helper Methods

- (void)reloadFeature {
  [self switchToFeature:-1];
}

- (void)switchToFeature:(NSInteger)index {
  for (UIView *subview in self.bottomStackView.arrangedSubviews) {
    [self.bottomStackView removeArrangedSubview:subview];
    [subview removeFromSuperview];
  }
  self.selectedFeature = index >= 0 ? index : self.selectedFeature;
  [self addFeatureControlsForFeature:self.selectedFeature];
}

- (void)addFeatureControlsForFeature:(NSInteger)index {

  NSUInteger bottomStackHeight = 0;

  NSArray *features = self.tabBarVC.templateMarkers[kFeatureArray];
  if (index < 0 || index >= features.count) {
    return;
  }
  Feature *feature = self.userInput.features[index];
  
  NSDictionary *featureDict = features[index];
  if (featureDict[kMarkerHead]) {
    UITextField *headlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerHeadline text:feature.headline placeholder:@"Headline text..." borderStyle:UITextBorderStyleRoundedRect];
    headlineField.delegate = self;
    [self.bottomStackView addArrangedSubview:headlineField];
    bottomStackHeight += headlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerSub]) {
    UITextField *subheadlineField = [[UITextField alloc] initWithMarkerType:HtmlMarkerSubheadline text:feature.subheadline placeholder:@"Subheadline text..." borderStyle:UITextBorderStyleRoundedRect];
    subheadlineField.delegate = self;
    [self.bottomStackView addArrangedSubview:subheadlineField];
    bottomStackHeight += subheadlineField.intrinsicContentSize.height + self.bottomStackSpacing;
  }
  if (featureDict[kMarkerBody]) {
    UITextView *bodyTextView = [[UITextView alloc] initWithMarkerType:HtmlMarkerBody text:feature.body placeholder:@"Body text..." borderStyle:UITextBorderStyleRoundedRect];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:bodyTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.bottomTextViewHeight];
    constraint.active = YES;
    bodyTextView.delegate = self;
    [self.bottomStackView addArrangedSubview:bodyTextView];
    bottomStackHeight += self.bottomTextViewHeight + self.bottomStackSpacing;
  }
}

- (void)assignImageRefsToUserInput {
  
  NSMutableArray *imageRefs = [[NSMutableArray alloc] init];
  for (NSUInteger index = 0; index < self.tabBarVC.images.count; index++) {
    
    NSString *imageFile = [NSString stringWithFormat:@"%@%02lu", kTemplateImagePrefix, index + 1];
    NSString *relativeFilepath = [kTemplateImageDirectory stringByAppendingPathComponent:imageFile];
    NSString *relativePathWithType = [relativeFilepath stringByAppendingPathExtension:kTemplateImageFiletype];
    
    [imageRefs addObject:relativePathWithType];
  }
  self.userInput.imageRefs = imageRefs;
}

- (void)insertUserInputIntoTemplateCopy {
  
  [self.tabBarVC.templateCopy insertTitle:self.userInput.title];
  [self.tabBarVC.templateCopy insertSubtitle:self.userInput.subtitle];
  [self.tabBarVC.templateCopy insertSummary:self.userInput.summary];
  [self.tabBarVC.templateCopy insertCopyright:self.userInput.copyright];
  for (NSUInteger index = 0; index < self.userInput.features.count; index++) {
    Feature *feature = self.userInput.features[index];
    [self.tabBarVC.templateCopy insertFeature:index headline:feature.headline];
    [self.tabBarVC.templateCopy insertFeature:index subheadline:feature.subheadline];
    [self.tabBarVC.templateCopy insertFeature:index body:feature.body];
  }
  for (NSUInteger index = 0; index < self.userInput.imageRefs.count; index++) {
    [self.tabBarVC.templateCopy insertImageReference:index imageSource:self.userInput.imageRefs[index]];
  }
}

- (void)saveUserInput {
  self.lastTextEditingView = nil;
  
  NSLog(@"saveUserInput");
  NSData *jsonData = [JsonService fromTemplateInput:self.userInput];
  [JsonService writeJsonFile:jsonData fileURL:self.tabBarVC.userJsonURL];
  
  [self writeIndexHtmlFile];
  [self writeImageFiles];
}

- (BOOL)writeIndexHtmlFile {
  
  if ([self.tabBarVC.templateCopy writeToURL:self.tabBarVC.indexHtmlURL]) {
    return YES;
  }
  return NO;
}

- (void)writeImageFiles {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *workingDirectory = [self.tabBarVC.documentsDirectory stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImageDirectory];

  if (self.tabBarVC.images.count > 0) {
    if (![fileManager fileExistsAtPath:imagesDirectory isDirectory:nil]) {
      NSError *error;
      [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
      if (error) {
        NSLog(@"Error! Cannot create directory: [%@] error: %@", imagesDirectory, error.localizedDescription);
        return;
      }
    }
  }

  for (NSUInteger index = 0; index < self.tabBarVC.images.count; index++) {
    
    UIImage *image = self.tabBarVC.images[index];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *imageFile = [NSString stringWithFormat:@"%@%02lu", kTemplateImagePrefix, index + 1];
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:imageFile];
    NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateImageFiletype];
    
    //NSLog(@"Writing image file: %@", pathWithType);
    NSError *error;
    [data writeToFile:pathWithType options:NSDataWritingAtomic error:&error];
    if (error) {
      NSLog(@"Error! Cannot write image file: [%@] error: %@", pathWithType, error.localizedDescription);
      return;
    }
  }
}

- (void)publishToGithub {
  
  if (![SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    UIViewController *oauthVC = [oauthStoryboard instantiateInitialViewController];
    [self.navigationController pushViewController:oauthVC animated:YES];
  }
  if ([SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount]) {
    UIStoryboard *publishStoryboard = [UIStoryboard storyboardWithName:@"Publish" bundle:[NSBundle mainBundle]];
    PublishViewController *publishVC = [publishStoryboard instantiateInitialViewController];
    
    FileManager *fileManager = [[FileManager alloc] init];
    NSArray *files = [fileManager enumerateFilesInDirectory:self.tabBarVC.templateDirectory documentsDirectory:self.tabBarVC.documentsDirectory];
    
    NSString *workingDirectory = [self.tabBarVC.documentsDirectory stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
    
    //publishVC.indexHtmlFilePath = workingDirectory;
    //publishVC.JSONfilePath = workingDirectory;
    
    //NSLog(@"OTHER FILES: %@", [[files firstObject] description]);
    //NSLog(@"IMAGES: %@", [[files lastObject] description]);
    //publishVC.supportingFilePaths = [files firstObject];
    //publishVC.imageFilePaths = [files lastObject];
    
    [self.navigationController pushViewController:publishVC animated:YES];
  }
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

#pragma mark - IBActions, Selector Methods

- (IBAction)featureSegmentedControlChange:(UISegmentedControl *)sender {
  [self switchToFeature:sender.selectedSegmentIndex];
}

- (void)saveButtonTapped {
  
  [self saveUserInput];
  [self publishToGithub];
}

- (void)doneButtonTapped {
  [self advanceNextResponder:self.lastTextEditingView];
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

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[DisplayTemplateViewController class]]) {
    [self saveUserInput];    
  }
  return YES;
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
      [self.tabBarVC.templateCopy insertTitle:textField.text];
      self.userInput.title = textField.text;
      break;
    case HtmlMarkerSubtitle:
      [self.tabBarVC.templateCopy insertSubtitle:textField.text];
      self.userInput.subtitle = textField.text;
      break;
    case HtmlMarkerHeadline:
    {
      [self.tabBarVC.templateCopy insertFeature: self.selectedFeature headline:textField.text];
      Feature *feature = self.userInput.features[self.selectedFeature];
      feature.headline = textField.text;
      break;
    }
    case HtmlMarkerSubheadline:
    {
      [self.tabBarVC.templateCopy insertFeature: self.selectedFeature subheadline:textField.text];
      Feature *feature = self.userInput.features[self.selectedFeature];
      feature.subheadline = textField.text;
      break;
    }
    case HtmlMarkerCopyright:
      [self.tabBarVC.templateCopy insertCopyright:textField.text];
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
      [self.tabBarVC.templateCopy insertSummary:textView.text];
      break;
    case HtmlMarkerBody:
    {
      [self.tabBarVC.templateCopy insertFeature: self.selectedFeature body:textView.text];
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
  self.lastTextEditingView = nil;
}

@end


