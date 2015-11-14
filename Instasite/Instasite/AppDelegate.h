//
//  AppDelegate.h
//  Instasite
//
//  Created by Sam Wilskey on 9/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *accessToken;      // retrieved from Keychain
@property (strong, nonatomic) NSString *userName;         // retrieved from UserDefaults

@end
