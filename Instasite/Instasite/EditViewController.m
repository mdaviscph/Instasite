//
//  EditViewController.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewController.h"
#import "SegmentedControl.h"
#import "Extensions.h"
#import "HtmlTemplate.h"
#import "InputGroup.h"
#import "InputCategory.h"
#import "InputField.h"
#import "Constants.h"
#import "TemplateTabBarController.h"
#import "FileService.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate, SegmentedControlDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet SegmentedControl *groupSegmentedControl;
@property (weak, nonatomic) IBOutlet SegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *temporaryFillerView;

@property (strong, nonatomic) UIView *lastTextEditingView;
@property (nonatomic) NSInteger maxFieldTag;

@property (strong, nonatomic) NSArray *sortedGroupKeys;
@property (strong, nonatomic) NSArray *sortedCategoryKeys;
@property (strong, nonatomic) NSString *selectedGroupName;
@property (strong, nonatomic) NSString *selectedCategoryName;

@property (strong, nonatomic) TemplateTabBarController *tabBarVC;

@end

@implementation EditViewController

- (void)setLastTextEditingView:(UIView *)lastTextEditingView {
  [_lastTextEditingView endEditing:YES];
  _lastTextEditingView = lastTextEditingView;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.temporaryFillerView removeFromSuperview];
  
  self.tabBarVC = (TemplateTabBarController *)self.tabBarController;
  self.tabBarVC.delegate = self;

  self.groupSegmentedControl.delegate = self;
  self.categorySegmentedControl.delegate = self;
  
  self.sortedGroupKeys = [self sortGroupKeys:self.tabBarVC.inputGroups];
  self.selectedGroupName = self.sortedGroupKeys[0];
  [self.groupSegmentedControl resetWithTitles:self.sortedGroupKeys];

  [self reloadGroup];
  
//  NSData *jsonData = [JsonService readJsonFile:self.tabBarVC.userJsonURL];
//  if (jsonData) {
//    self.userInput = [JsonService templateInputFrom:jsonData];
//    [self insertUserInputIntoTemplateCopy];
//  } else {
//    self.userInput = [[TemplateInput alloc] initWithFeatureCount:self.featureMarkers.count];
//  }
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.navigationController.navigationBarHidden = NO;
  self.tabBarVC.navigationItem.title = self.tabBarVC.repoName;
  self.tabBarVC.navigationItem.rightBarButtonItem = nil;
  self.tabBarVC.navigationItem.leftBarButtonItem = nil;
  
  [self assignImageRefsToUserInput];
  //[self insertUserInputIntoTemplateCopy];
  
  [self startObservingKeyboardEvents];
}

-(void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self stopObservingKeyboardEvents];
}

#pragma mark - IBActions, Selector Methods
- (IBAction)groupSegmentedControlChange:(SegmentedControl *)sender {
  [self switchToGroup:sender.selectedSegmentIndex];
}
- (IBAction)categorySegmentedControlChange:(SegmentedControl *)sender {
  [self switchToCategory:sender.selectedSegmentIndex];
}

- (void)saveButtonTapped {
  
  [self saveUserInput];
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

#pragma mark - Helper Methods

- (NSArray *)sortGroupKeys:(InputGroupDictionary *)groups {
  return [groups keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputGroup *)obj1 tag] > [(InputGroup *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
}
- (NSArray *)sortCategoryKeys:(InputCategoryDictionary *)groups {
  return [groups keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputCategory *)obj1 tag] > [(InputCategory *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
}

- (void)reloadGroup {
  [self switchToGroup:-1];
}
- (void)reloadCategory {
  [self switchToCategory:-1];
}

- (void)switchToGroup:(NSInteger)index {
  self.selectedGroupName = index >= 0 ? self.sortedGroupKeys[index] : self.selectedGroupName;
  InputGroup *group = self.tabBarVC.inputGroups[self.selectedGroupName];
  self.sortedCategoryKeys = [self sortCategoryKeys:group.categories];
  self.selectedCategoryName = self.sortedCategoryKeys[0];
  [self.categorySegmentedControl resetWithTitles:self.sortedCategoryKeys];
  [self switchToCategory:0];
}
- (void)switchToCategory:(NSInteger)index {
  for (UIView *subview in self.stackView.arrangedSubviews) {
    if (![subview isKindOfClass:[SegmentedControl class]]) {
      [self.stackView removeArrangedSubview:subview];
      [subview removeFromSuperview];
    }
  }
  self.selectedCategoryName = index >= 0 ? self.sortedCategoryKeys[index] : self.selectedCategoryName;
  [self addControlsForFieldsInGroup:self.selectedGroupName andCategory:self.selectedCategoryName];
}

- (void)addControlsForFieldsInGroup:(NSString *)groupName andCategory:(NSString *)categoryName {

  InputGroup *group = self.tabBarVC.inputGroups[groupName];
  InputCategoryDictionary *categories = group.categories;
  InputCategory *category = categories[categoryName];
  InputFieldDictionary *fields = category.fields;
  NSArray *sortedFieldKeys = [fields keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    return [(InputField *)obj1 tag] > [(InputField *)obj2 tag] ? NSOrderedDescending : NSOrderedAscending;
  }];
  
  self.maxFieldTag = 0;
  for (NSString *fieldName in sortedFieldKeys) {
    
    InputField *field = fields[fieldName];
    self.maxFieldTag = MAX(self.maxFieldTag, field.tag);

    if (field.type == FieldTXF) {
      UITextField *textField = [[UITextField alloc] initWithTag:field.tag text:field.text placeholder:field.placeholder borderStyle:UITextBorderStyleRoundedRect];
      textField.delegate = self;
      [self.stackView addArrangedSubview:textField];
      
    } else if (field.type == FieldTXV) {
      UITextView *textView = [[UITextView alloc] initWithTag:field.tag text:field.text placeholder:field.placeholder borderStyle:UITextBorderStyleRoundedRect];
      textView.delegate = self;
      NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:120];
      constraint.active = YES;
      [self.stackView addArrangedSubview:textView];
    }
  }
}

- (void)assignImageRefsToUserInput {
  
  NSMutableDictionary *imageRefs = [[NSMutableDictionary alloc] init];
  for (NSString *fileName in self.tabBarVC.images.allKeys) {
    
    NSString *relativeFilepath = [kTemplateImageDirectory stringByAppendingPathComponent:fileName];
    NSString *relativePathWithExtension = [relativeFilepath stringByAppendingPathExtension:kTemplateImageExtension];
    
    // marker name is the file name
    [imageRefs setObject:relativePathWithExtension forKey:fileName];
  }
//  self.userInput.imageRefs = imageRefs;
}

- (void)saveUserInput {
  self.lastTextEditingView = nil;
  
  NSLog(@"saveUserInput");
//  NSData *jsonData = [JsonService fromTemplateInput:self.userInput];
//  [JsonService writeJsonFile:jsonData fileURL:self.tabBarVC.userJsonURL];
  
  [self writeIndexHtmlFile];
  [self writeImageFiles];
}

- (BOOL)writeIndexHtmlFile {
  
  if ([self.tabBarVC.templateCopy writeToURL:self.tabBarVC.indexHtmlURL withInputGroups:self.tabBarVC.inputGroups]) {
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

  for (NSString *fileName in self.tabBarVC.images.allKeys) {
    
    NSData *data = self.tabBarVC.images[fileName];
    
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:fileName];
    NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateImageExtension];
    
    //NSLog(@"Writing image file: %@", pathWithType);
    NSError *error;
    [data writeToFile:pathWithType options:NSDataWritingAtomic error:&error];
    if (error) {
      NSLog(@"Error! Cannot write image file: [%@] error: %@", pathWithType, error.localizedDescription);
      return;
    }
  }
}

- (void)advanceNextResponder:(UIView *)textEditingView {

  NSInteger tag = textEditingView.tag;
  UIView *parentView = self.stackView;
  UIResponder* nextResponder;
  do {
    nextResponder = [parentView viewWithTag:++tag];
  } while (!nextResponder && tag <= self.maxFieldTag);
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

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
  if (![viewController isKindOfClass:[EditViewController class]]) {
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
  InputGroup *group = self.tabBarVC.inputGroups[self.selectedGroupName];
  InputCategoryDictionary *categories = group.categories;
  InputCategory *category = categories[self.selectedCategoryName];
  
  [category setFieldText:textField.text forTag:textField.tag];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
  [textView clearPlaceholder];
  self.lastTextEditingView = textView;
  self.tabBarVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  self.tabBarVC.navigationItem.rightBarButtonItem = nil;
  
  InputGroup *group = self.tabBarVC.inputGroups[self.selectedGroupName];
  InputCategoryDictionary *categories = group.categories;
  InputCategory *category = categories[self.selectedCategoryName];
  
  [category setFieldText:textView.text forTag:textView.tag];
}

#pragma mark - SegmentedControlDelegate

// this protocol is defined in SegmentedControl.h and used so we can force editing to
// end, prior to the segnmentedControl index changing, for any textViews since there is
// no textViewShouldReturn delegate method
- (void)segmentedControlIndexWillChange:(UISegmentedControl *)sender {
  self.lastTextEditingView = nil;
}

@end


