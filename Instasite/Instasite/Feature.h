//
//  Feature.h
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feature : NSObject

@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSString *subheadline;
@property (strong, nonatomic) NSString *body;

- (NSString *)description;

@end
