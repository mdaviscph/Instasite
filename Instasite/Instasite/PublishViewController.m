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


@interface PublishViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFieldRepoName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDescription;


@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.textFieldRepoName.delegate = self;
  self.textFieldDescription.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createRepoAction:(UIButton *)sender {

//  [GitHubService repoForSearch];


  [GitHubService serviceForRepoNameInput:self.textFieldRepoName.text descriptionInput:self.textFieldDescription.text  completionHandler:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Error: %@",error);
    } else {
      
    }
  }];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
  
  [textField resignFirstResponder];
  
  return true;
}
- (IBAction)downloadJSON:(id)sender {
  
  [GitHubPullService getJSONFromGithub:@"instasite.json" username:@"myUsername" email:@"myemail@domain.com" templateName:@"mytemplate" completionHandler:^(NSError *username) {
    
  }];
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
