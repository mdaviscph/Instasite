//
//  Repo.h
//  Instasite
//
//  Created by mike davis on 11/4/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repo : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *aDescription;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSDate *updatedAt;

- (instancetype)initWithName:(NSString *)name description:(NSString *)description owner:(NSString *)owner updatedAt:(NSDate *)updatedAt;

@end
