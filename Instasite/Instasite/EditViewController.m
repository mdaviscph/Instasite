//
//  EditViewController.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "EditViewController.h"
#import "SegmentedControl.h"
#import "TemplateTabBarController.h"
#import "Extensions.h"
#import "HtmlTemplate.h"
#import "UserInput.h"
#import "InputGroup.h"
#import "InputCategory.h"
#import "InputField.h"
#import "Constants.h"
#import "FileService.h"

@interface EditViewController () <UITextFieldDelegate, UITextViewDelegate, SegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet SegmentedControl *groupSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupSegmentedControlConstraint;
@property (weak, nonatomic) IBOutlet SegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categorySegmentedControlConstraint;
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

  self.groupSegmentedControl.delegate = self;
  self.categorySegmentedControl.delegate = self;
  
  self.sortedGroupKeys = [self sortGroupKeys:self.tabBarVC.userInput.groups];
  self.selectedGroupName = self.sortedGroupKeys.firstObject;
  [self.groupSegmentedControl resetWithTitles:self.sortedGroupKeys];

  [self reloadGroup];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.tabBarVC.navigationItem.title = self.tabBarVC.repoName;
  self.tabBarVC.navigationItem.rightBarButtonItems = nil;
  
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
  BOOL hideGroupSegmentedControl = self.sortedGroupKeys.count <= 1;
  self.groupSegmentedControl.hidden = hideGroupSegmentedControl;
  self.groupSegmentedControlConstraint.active = !hideGroupSegmentedControl;
  
  InputGroup *group = self.tabBarVC.userInput.groups[self.selectedGroupName];
  self.sortedCategoryKeys = [self sortCategoryKeys:group.categories];
  self.selectedCategoryName = self.sortedCategoryKeys.firstObject;
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
  BOOL hideCategorySegmentedControl = self.sortedCategoryKeys.count <= 1;
  self.categorySegmentedControl.hidden = hideCategorySegmentedControl;
  self.categorySegmentedControlConstraint.active = !hideCategorySegmentedControl;
  
  [self addControlsForFieldsInGroup:self.selectedGroupName andCategory:self.selectedCategoryName];
}

- (void)addControlsForFieldsInGroup:(NSString *)groupName andCategory:(NSString *)categoryName {

  InputGroup *group = self.tabBarVC.userInput.groups[groupName];
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
      NSString *placeholder = field.placeholder ? [NSString stringWithFormat:@"%@: %@", fieldName, field.placeholder] : fieldName;
      UITextField *textField = [[UITextField alloc] initWithTag:field.tag text:field.text placeholder:placeholder borderStyle:UITextBorderStyleRoundedRect];
      textField.delegate = self;
      [self.stackView addArrangedSubview:textField];
      
    } else if (field.type == FieldTXV) {
      NSString *placeholder = field.placeholder ? [NSString stringWithFormat:@"%@: %@", fieldName, field.placeholder] : fieldName;
      UITextView *textView = [[UITextView alloc] initWithTag:field.tag text:field.text placeholder:placeholder borderStyle:UITextBorderStyleRoundedRect];
      textView.delegate = self;
      NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:120];
      constraint.active = YES;
      [self.stackView addArrangedSubview:textView];
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

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  self.lastTextEditingView = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self advanceNextResponder:textField];
  return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  InputGroup *group = self.tabBarVC.userInput.groups[self.selectedGroupName];
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
  
  InputGroup *group = self.tabBarVC.userInput.groups[self.selectedGroupName];
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


