//
//  OAuthJsonResponse.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthJsonResponse : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *scope;

- (instancetype)initFromJson:(NSDictionary *)json;

@end
