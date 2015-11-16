//
//  CommitTreeJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/20/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommitTreeJsonRequest : NSObject

@property (strong, nonatomic) NSString *treeSha;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *parentSha;

- (instancetype)initWithTreeSha:(NSString *)treeSha message:(NSString *)message parentSha:(NSString *)parentSha;
- (NSDictionary *)createJson;

@end
