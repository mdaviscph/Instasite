//
//  UserReposJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserReposJsonRequest : NSObject

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *sort;
@property (strong, nonatomic) NSString *direction;

- (instancetype)initWithType:(NSString *)type sort:(NSString *)sort direction:(NSString *)direction;
- (instancetype)initWithType:(NSString *)type;

- (NSDictionary *)createJson;

@end
