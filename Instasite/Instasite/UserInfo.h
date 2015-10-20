//
//  UserInfo.h
//  Instasite
//
//  Created by mike davis on 10/7/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *email;

- (instancetype)initFromJSON:(NSDictionary *)json;
- (instancetype)initFromUserDefaults;
- (void)saveToUserDefaults;

@end
