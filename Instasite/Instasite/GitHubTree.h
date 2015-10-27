//
//  GitHubTree.h
//  Instasite
//
//  Created by mike davis on 10/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@interface GitHubTree : NSObject

- (instancetype)initWithFiles:(FileInfoArray *)files userName:(NSString *)userName repoName:(NSString *)repoName branch:(NSString *)branch accessToken:(NSString *)accessToken;

- (void)createAndCommitWithCompletion:(void(^)(NSError *))finalCompletion;

@end
