//
//  CreateTreeJson.m
//  Instasite
//
//  Created by mike davis on 9/30/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "CreateTreeJson.h"
#import "FileJson.h"

@implementation CreateTreeJson

- (instancetype)initWithBaseTree:(NSString *)baseTree tree:(NSArray *)tree {
  self = [super init];
  if (self) {
    _baseTree = baseTree;
    _tree = tree;
  }
  return self;
}

- (NSDictionary *)createJson {
  NSMutableArray *treeJson = [[NSMutableArray alloc] init];
  for (FileJson *file in self.tree) {
    [treeJson addObject:[file createJson]];
  }
  if (self.baseTree) {
    return @{@"base_tree":self.baseTree, @"tree":treeJson};
  }
  return @{@"tree":treeJson};
}

@end
