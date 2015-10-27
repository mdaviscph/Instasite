//
//  CommitTreeJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommitTreeJsonRequest : NSObject

@property (strong, nonatomic) NSString *sha;
@property (strong, nonatomic) NSString *message;

- (instancetype)initWithSha:(NSString *)sha message:(NSString *)message;
- (NSDictionary *)createJson;

@end
