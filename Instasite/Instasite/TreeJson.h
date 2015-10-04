//
//  TreeJson.h
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeJson : NSObject

@property (strong, nonatomic) NSString *commitSHA;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSString *authorEmail;
@property (strong, nonatomic) NSString *committerName;
@property (strong, nonatomic) NSString *committerEmail;
@property (strong, nonatomic) NSString *treeSHA;
@property (strong, nonatomic) NSString *treeUrl;

@end
