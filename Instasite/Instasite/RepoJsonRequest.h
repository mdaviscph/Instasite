//
//  RepoJsonRequest.h
//  Instasite
//
//  Created by mike davis on 10/24/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepoJsonRequest : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *comment;
@property (nonatomic)         BOOL commitReadme;
@property (strong, nonatomic) NSString *license;

- (instancetype)initWithName:(NSString *)name comment:(NSString *)comment;

- (NSDictionary *)createJson;

@end
