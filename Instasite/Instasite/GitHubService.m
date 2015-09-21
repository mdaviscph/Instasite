//
//  GitHubService.m
//  Instasite
//
//  Created by Sam Wilskey on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "GitHubService.h"
#import "Keys.h"
#import <AFNetworking/AFNetworking.h>

@implementation GitHubService

+ (void)exchangeCodeInURL:(NSURL *)url {
  
  NSString *code = url.query;
  NSString *requestURL = [NSString stringWithFormat:@"https://github.com/login/oauth/access_token?\(code)&client_id=%@&client_secret=%@", kClientId, kClientSecret];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  [manager POST:requestURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
  }];
    let request = NSMutableURLRequest(URL: NSURL(string: "https://github.com/login/oauth/access_token?\(code)&client_id=\(kClientId)&client_secret=\(kClientSecret)")!)
    request.HTTPMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if let httpResponse = response as? NSHTTPURLResponse {
        
        var jsonError: NSError?
        if let rootObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String : AnyObject],
          token = rootObject["access_token"] as? String {
            KeychainService.saveToken(token)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              NSNotificationCenter.defaultCenter().postNotificationName(kTokenNotification, object: nil)
            })
          }
      }
    }).resume()
}

@end
