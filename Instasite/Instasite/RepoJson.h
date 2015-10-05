//
//  RepoJson.h
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepoJson : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *aDescription;
@property (strong, nonatomic) NSString *htmlURL;

- (instancetype)initFromJSON:(NSDictionary *)json;

@end
