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
#import "TemplateData.h"
#import "Feature.h"
#import "JsonData.h"
#import "Constants.h"
#import "TemplateTabBarController.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *topStackView;
@property (weak, nonatomic) IBOutlet UIStackView *bottomStackView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *featureSegmentedControl;

@property (nonatomic) NSUInteger topStackSpacing;
@property (nonatomic) NSUInteger bottomStackSpacing;
@property (nonatomic) NSUInteger topTextViewHeight;
@property (nonatomic) NSUInteger bottomTextViewHeight;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;
@property (strong, nonatomic) NSDictionary *markers;

@property (strong, nonatomic) TemplateData *userData;

@end

@implementation EditViewController

- (IBAction)publishButtonTapped:(UIButton *)sender {
  
  NSData *jsonData = [JsonData fromTemplateData:self.userData];
  [self writeJsonFile:jsonData filename:kTemplateJsonFilename ofType:kTemplateJsonFiletype];
  
  [self writeWorkingFile:kTemplateWorkingFilename ofType:kTemplateWorkingFiletype];
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
  
  self.userData = [[TemplateData alloc] init];
  NSMutableArray *mutableFeatures = [[NSMutableArray alloc] init];
  for (NSUInteger index = 0; index < features.count; index++) {
    [mutableFeatures addObject:[[Feature alloc] init]];
  }
  self.userData.features = mutableFeatures;
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

- (BOOL)writeWorkingFile:(NSString *)filename ofType:(NSString *)type {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  if ([self.tabBarVC.workingHtml writeToFile:filename ofType:type inDirectory:self.tabBarVC.templateDirectory]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, type, self.tabBarVC.templateDirectory);
  return NO;
}

- (BOOL)writeJsonFile:(NSData *)data filename:(NSString *)filename ofType:(NSString *)type {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *workingDirectory = [documentsPath stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:filename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:type];
  
  NSLog(@"Write file: %@", pathWithType);
  if ([[NSFileManager defaultManager] createFileAtPath:pathWithType contents:data attributes:nil]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, type, self.tabBarVC.templateDirectory);
  return NO;
}

- (void)actionSheetForImageSelection:(UIButton *)button {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select an Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.view;
  alert.popoverPresentationController.sourceRect = button.frame;
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }];
    [alert addAction:action];
  }
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [alert addAction:action];
  }
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Saved Photos Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [self startImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    [alert addAction:action];
  }
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:cancelAction];
  [self presentViewController:alert animated:YES completion: nil];
}

- (void)startImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
  UIImagePickerController *imagePC = [[UIImagePickerController alloc] init];
  imagePC.delegate = self;
  imagePC.allowsEditing = YES;
  imagePC.sourceType = sourceType;
  [self presentViewController:imagePC animated:YES completion: nil];
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
    {
      NSLog(@"image src button pressed");
      [self actionSheetForImageSelection:sender];
      break;
    }
  }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
  
  switch (textField.tag) {
    case HtmlMarkerTitle:
      [self.tabBarVC.workingHtml insertTitle:textField.text];
      self.userData.title = textField.text;
      break;
    case HtmlMarkerSubtitle:
      [self.tabBarVC.workingHtml insertSubtitle:textField.text];
      self.userData.subtitle = textField.text;
      break;
    case HtmlMarkerHeadline:
    {
      NSInteger index = self.featureSegmentedControl.selectedSegmentIndex;
      [self.tabBarVC.workingHtml insertFeature: index headline:textField.text];
      Feature *feature = self.userData.features[index];
      feature.headline = textField.text;
      break;
    }
    case HtmlMarkerSubheadline:
    {
      NSInteger index = self.featureSegmentedControl.selectedSegmentIndex;
      [self.tabBarVC.workingHtml insertFeature: index subheadline:textField.text];
      Feature *feature = self.userData.features[index];
      feature.subheadline = textField.text;
      break;
    }
    case HtmlMarkerCopyright:
      [self.tabBarVC.workingHtml insertCopyright:textField.text];
      self.userData.title = textField.text;
      break;
  }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {

  switch (textView.tag) {
    case HtmlMarkerSummary:
      [self.tabBarVC.workingHtml insertSummary:textView.text];
      break;
    case HtmlMarkerBody:
    {
      NSInteger index = self.featureSegmentedControl.selectedSegmentIndex;
      [self.tabBarVC.workingHtml insertFeature: index body:textView.text];
      Feature *feature = self.userData.features[index];
      feature.body = textView.text;
      break;
    }
  }
}

#pragma mark - UIImagePickerControllerDelegate, UINavigationControllerDelegate
 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  [picker dismissViewControllerAnimated:YES completion:nil];
  UIImage *image = info[UIImagePickerControllerEditedImage];
  NSData *data = UIImageJPEGRepresentation(image, 1.0);

  NSInteger index = self.featureSegmentedControl.selectedSegmentIndex;

  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *workingDirectory = [documentsPath stringByAppendingPathComponent:self.tabBarVC.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImagesDirectory];
  NSString *filepath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"image%ld", (long)index]];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:@"jpg"];
  
  NSLog(@"Write file: %@", pathWithType);
  if (![[NSFileManager defaultManager] createFileAtPath:pathWithType contents:data attributes:nil]) {
    NSLog(@"Error! Cannot create file: %@", pathWithType);
    return;
  }
  
  [self.tabBarVC.workingHtml insertImageReference:index imageSource:pathWithType];
  Feature *feature = self.userData.features[index];
  feature.imageSrc = pathWithType;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

@end


