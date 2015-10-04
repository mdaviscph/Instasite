//
//  PublishViewController.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PublishViewController.h"
#import "GitHubService.h"
#import "GitHubPullService.h"
#import "ImageFile.h"
#import "CSSFile.h"

@interface PublishViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

@property (weak, nonatomic) IBOutlet UITextField *textFieldRepoName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDescription;

@end

@implementation PublishViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.textFieldRepoName.delegate = self;
  self.textFieldDescription.delegate = self;
}

- (IBAction)createRepoAction:(UIButton *)sender {

  [GitHubService serviceForRepoNameInput:self.textFieldRepoName.text descriptionInput:self.textFieldDescription.text completion:^(NSError *error) {
    if (error) {
      // TODO - Alert popover
      return;
    }
    
    [GitHubService getUsernameFromGithub:^(NSError *error, NSString *username) {
      
      if (error) {
        // TODO - Alert popover
        return;
      }
      
      [GitHubService pushFilesToGithub:self.textFieldRepoName.text indexHtmlFile:self.indexHtmlFilePath user:username email:self.textFieldEmail.text completion:^(NSError *error) {
        if (error) {
          // TODO - Alert popover
          return;
        }
        [GitHubService pushJSONToGithub:self.JSONfilePath user:username email:self.textFieldEmail.text forRepo:self.textFieldRepoName.text completion:^(NSError *error) {
          if (error) {
            // TODO - Alert popover
            return;
          }
          
          NSMutableArray *cssFiles = [[NSMutableArray alloc] initWithArray:self.supportingFilePaths];
          [GitHubService pushCSSToGithub:cssFiles user:username email:self.textFieldEmail.text forRepo:self.textFieldRepoName.text completion:^(NSError *error) {
            if (error) {
              // TODO - Alert popover
              return;
            }
            // success
          }];
        }];
      }];
      //  for (ImageFile *imageFile in self.imageFilePaths) {
      //    [GitHubService pushImagesToGithub:imageFile.fileName imagePath:imageFile.filePath user:username email:self.textFieldEmail.text forRepo:self.textFieldRepoName.text];
      //  }
    }];
  }];
}

- (IBAction)downloadJSON:(id)sender {
  
  //[GitHubPullService getJSONFromGithub:@"instasite.json" username:@"myUsername" email:@"myemail@domain.com" templateName:@"mytemplate" completion:^(NSError *username) {
    
  //}];
  
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  [textField resignFirstResponder];
  
  return true;
}

@end
