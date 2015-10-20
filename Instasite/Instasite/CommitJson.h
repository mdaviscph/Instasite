//
//  CommitJson.h
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommitJson : NSObject

@property (strong, nonatomic) NSString *objectSHA;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) NSString *objectUrl;

- (instancetype)initFromJSON:(NSDictionary *)json;

@end
