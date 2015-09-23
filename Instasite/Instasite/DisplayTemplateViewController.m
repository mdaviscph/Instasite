//
//  DisplayTemplateViewController.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "DisplayTemplateViewController.h"
#import <WebKit/WebKit.h>
#import "HtmlTemplate.h"
#import "Constants.h"
@interface DisplayTemplateViewController () <WKNavigationDelegate>


@end

@implementation DisplayTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  WKWebView *webView = [[WKWebView alloc]initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height- kTabBarHeight)];
  [self.view addSubview: webView];
  webView.navigationDelegate = self;
  
  NSURL *htmlUrl = [self displayTemplate];
  [webView loadFileURL:htmlUrl allowingReadAccessToURL:htmlUrl];
}

- (NSURL *)displayTemplate {
  switch (self.pathItem) {
    case 0: {
      HtmlTemplate *htmlTemp = [[HtmlTemplate alloc]init];
      NSURL *url = [htmlTemp genURL:@"index" ofType:@"html" inDirectory:@"startbootstrap-one-page-wonder-1.0.3"];
      return url;
    }
    case 1: {
      HtmlTemplate *htmlTemp = [[HtmlTemplate alloc]init];
      NSURL *url = [htmlTemp genURL:@"index" ofType:@"html" inDirectory:@"startbootstrap-agency-1.0-2.4"];
      return url;
    }
    case 2: {
      HtmlTemplate *htmlTemp = [[HtmlTemplate alloc]init];
      NSURL *url = [htmlTemp genURL:@"index" ofType:@"html" inDirectory:@"startbootstrap-freelancer-1.0.3"];
      return url;
    }
    case 3:{
      HtmlTemplate *htmlTemp = [[HtmlTemplate alloc]init];
      NSURL *url = [htmlTemp genURL:@"index" ofType:@"html" inDirectory:@"startbootstrap-creative-1.0.1"];
      return url;
    }
    case 4:{
      HtmlTemplate *htmlTemp = [[HtmlTemplate alloc]init];
      NSURL *url = [htmlTemp genURL:@"index" ofType:@"html" inDirectory:@"startbootstrap-clean-blog-1.0.3"];
      return url;
    }
    default:
      return nil;
  }
  return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
