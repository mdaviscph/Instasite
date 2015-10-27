//
//  OAuthJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthJsonRequest : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *clientSecret;

- (instancetype)initWithCode:(NSString *)code clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (NSDictionary *)createJson;

@end
