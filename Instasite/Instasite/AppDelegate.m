//
//  AppDelegate.m
//  Instasite
//
//  Created by Sam Wilskey on 9/19/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>
#import <SSKeychain/SSKeychain.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize accessToken = _accessToken;
- (NSString *)accessToken {
  if (!_accessToken) {
    _accessToken = [SSKeychain passwordForService:kSSKeychainService account:kSSKeychainAccount];
  }
  return _accessToken;
}
- (void)setAccessToken:(NSString *)accessToken {
  _accessToken = accessToken;
  [SSKeychain setPassword:accessToken forService:kSSKeychainService account:kSSKeychainAccount];
  NSLog(@"Access token saved to keychain.");
}

@synthesize userName = _userName;
- (NSString *)userName {
  if (!_userName) {
    _userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsUserNameKey];
  }
  return _userName;
}
- (void)setUserName:(NSString *)userName {
  _userName = userName;
  [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kUserDefaultsUserNameKey];
  NSLog(@"User name saved to user defaults.");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [[AFNetworkReachabilityManager sharedManager] startMonitoring];
  
  return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
  
  //NSLog(@"AppDelegate application:openURL: [%@]", url.absoluteString);
  [[NSNotificationCenter defaultCenter] postNotificationName:kOpenURLnotificationName object:nil userInfo:@{kOpenURLdictionaryKey : url}];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
