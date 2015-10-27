//
//  RefJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefJsonRequest : NSObject

@property (strong, nonatomic) NSString *ref;
@property (strong, nonatomic) NSString *sha;

- (instancetype)initWithRef:(NSString *)ref sha:(NSString *)sha;
- (NSDictionary *)createJson;

@end
