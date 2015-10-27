//
//  RefJsonResponse.h
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefJsonResponse : NSObject

@property (strong, nonatomic) NSString *ref;
@property (strong, nonatomic) NSString *objectSha;
@property (strong, nonatomic) NSString *objectType;

- (instancetype)initFromJson:(NSDictionary *)json;

@end
