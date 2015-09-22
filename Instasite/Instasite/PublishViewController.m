//
//  PublishViewController.m
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "PublishViewController.h"
#import "GitHubService.h"

@interface PublishViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFieldRepoName;

@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createRepoAction:(UIButton *)sender {

//  [GitHubService repoForSearch];
  [GitHubService serviceForRepoNameInput:nil completionHandler:^(NSError *error) {
    if (error != nil) {
      NSLog(@"Error: %@",error);
    }
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
