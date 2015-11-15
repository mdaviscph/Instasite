//
//  InitialViewController.m
//  Instasite
//
//  Created by mike davis on 11/11/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "InitialViewController.h"
#import "TemplatePickerViewController.h"
#import "TemplateTabBarController.h"
#import "RepoPickerViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface InitialViewController () <TemplatePickerDelegate, RepoPickerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *webPageButton;
@property (weak, nonatomic) IBOutlet UIButton *templateButton;

@property (strong, nonatomic) NSString *repoName;
@property (strong, nonatomic) NSString *templateName;       // note: currently templateName is same as template directory

@end

@implementation InitialViewController

@synthesize repoName = _repoName;
- (NSString *)repoName {
  if (!_repoName) {
    _repoName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsRepoNameKey];
  }
  return _repoName;
}
- (void)setRepoName:(NSString *)repoName {
  _repoName = repoName;
  if (_repoName) {
    [[NSUserDefaults standardUserDefaults] setObject:_repoName forKey:kUserDefaultsRepoNameKey];
    [self.webPageButton setTitle:_repoName forState:UIControlStateNormal];
  } else {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kUserDefaultsRepoNameKey];
    [self.webPageButton setTitle:kUnpublishedRepoName forState:UIControlStateNormal];
  }
}

@synthesize templateName = _templateName;
- (NSString *)templateName {
  if (!_templateName) {
    _templateName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsTemplateNameKey];
  }
  return _templateName;
}
- (void)setTemplateName:(NSString *)templateName {
  _templateName = templateName;
  if (_templateName) {
    [[NSUserDefaults standardUserDefaults] setObject:_templateName forKey:kUserDefaultsTemplateNameKey];
    [self.templateButton setTitle:_templateName forState:UIControlStateNormal];
  }
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.repoName) {
    [self.webPageButton setTitle:self.repoName forState:UIControlStateNormal];
  } else {
    [self.webPageButton setTitle:kUnpublishedRepoName forState:UIControlStateNormal];
  }
  if (self.templateName) {
    [self.templateButton setTitle:self.templateName forState:UIControlStateNormal];
  } else {
    [self setTemplateName:kDefaultTemplateName];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = NO;   // need to reset due to OauthVC hidding navigation bar
}

#pragma mark - IBActions, Selector Methods

- (IBAction)webPageButtonTapped:(UIButton *)sender {
  [self actionSheetForWebPage];
}
- (IBAction)templateButtonTapped:(UIButton *)sender {
  [self actionSheetForTemplate];
}

#pragma mark - Helper Methods

- (void)signUpOrLogInIfNeeded {
  if (![(AppDelegate *)[UIApplication sharedApplication].delegate accessToken]) {
    UIStoryboard *oauthStoryboard = [UIStoryboard storyboardWithName:@"Oauth" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[oauthStoryboard instantiateInitialViewController] animated:YES];
  }
}

- (void)actionSheetForWebPage {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.webPageButton;
  alert.popoverPresentationController.sourceRect = self.webPageButton.bounds;
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Edit and Publish" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self editWebPage];
  }];
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self renameWebPage];
  }];
  [alert addAction:action2];
  UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Choose a GitHub Repository" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self pickRepository];
  }];
  [alert addAction:action3];
  UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"New" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self newWebPage];
  }];
  [alert addAction:action4];
  UIAlertAction *action5 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action5];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)actionSheetForTemplate {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  alert.popoverPresentationController.sourceView = self.templateButton;
  alert.popoverPresentationController.sourceRect = self.templateButton.bounds;
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Choose a Template" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self pickTemplate];
  }];
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)editWebPage {
  TemplateTabBarController *tabBarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplateTabBarVC"];

  tabBarVC.documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

  tabBarVC.repoName = self.repoName;
  tabBarVC.templateDirectory = self.templateName;

  NSLog(@"template directory: %@", tabBarVC.templateDirectory);
  [self.navigationController pushViewController:tabBarVC animated:YES];
}

- (void)renameWebPage {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
  alert.modalPresentationStyle = UIModalPresentationPopover;
  
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    if (self.repoName) {
      textField.text = self.webPageButton.currentTitle;
      textField.clearButtonMode = UITextFieldViewModeAlways;
    } else {
      textField.placeholder = @"Web Page Repository";
    }
  }];
  
  UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    UITextField *textField = alert.textFields.firstObject;
    if (textField.text.length > 0) {
      self.repoName = textField.text;
    }
  }];
  [alert addAction:action1];
  UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Cancel" style:UIAlertActionStyleCancel handler:nil];
  [alert addAction:action2];

  [self presentViewController:alert animated:YES completion:nil];
}

- (void)pickRepository {
  RepoPickerViewController *repoPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RepoPickerVC"];
  
  [self signUpOrLogInIfNeeded];
  
  NSString *accessToken = [(AppDelegate *)[UIApplication sharedApplication].delegate accessToken];
  
  if (accessToken) {
    repoPickerVC.delegate = self;
    repoPickerVC.accessToken = accessToken;
    [self.navigationController pushViewController:repoPickerVC animated:YES];
  }
}

- (void)newWebPage {
  self.repoName = nil;
}

- (void)pickTemplate {
  TemplatePickerViewController *templatePickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TemplatePickerVC"];
  
  templatePickerVC.delegate = self;
  
  [self.navigationController pushViewController:templatePickerVC animated:YES];
}

#pragma mark - RepoPickerDelegate

- (void)repoPicker:(RepoPickerViewController *)picker didFinishPickingWithName:(NSString *)name {
  [self.navigationController popViewControllerAnimated:YES];
 
  if (name.length > 0) {
    self.repoName = name;
  }
}

- (void)repoPickerDidCancel:(RepoPickerViewController *)picker {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)repoPicker:(RepoPickerViewController *)picker didFailWithError:(NSError *)error {

  // TODO - alert popover saying Log In and then call signUpOrLogInIfNeeded again
  // TODO - only reset accessToken if error status is 401
  [(AppDelegate *)[UIApplication sharedApplication].delegate setAccessToken:nil];
}

#pragma mark - TemplatePickerDelegate

- (void)templatePicker:(TemplatePickerViewController *)picker didFinishPickingWithName:(NSString *)name {
  [self.navigationController popViewControllerAnimated:YES];
  
  if (name.length > 0) {
    self.templateName = name;
  }
}

- (void)templatePickerDidCancel:(TemplatePickerViewController *)picker {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)templatePicker:(TemplatePickerViewController *)picker didFailWithError:(NSError *)error {
  
}

@end
