//
//  GitHubServiceTest.m
//  Instasite
//
//  Created by Sam Wilskey on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GitHubService.h"

@interface GitHubServiceTest : XCTestCase

@end

@implementation GitHubServiceTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateRepo {
  [GitHubService serviceForRepoNameInput:@"TestRepo1" descriptionInput:@"This is a Test Repo" completionHandler:^(NSError *error) {
    XCTAssertNil(error);
  }];
}
@end
