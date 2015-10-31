//
//  InputGroup.m
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "InputGroup.h"
#import "InputCategory.h"
#import "TemplateField.h"

@implementation InputGroup

- (instancetype)initFromTemplateField:(TemplateField *)templateField {
  self = [super init];
  if (self) {
    _name = templateField.groupName;
    _categories = [[InputCategoryDictionary alloc] init];
  }
  return self;
}

- (NSDictionary *)createJson {
  NSMutableDictionary *jsonGroupDictionary = [[NSMutableDictionary alloc] init];
  NSMutableArray *jsonCategoryArray = [[NSMutableArray alloc] init];
  
  jsonGroupDictionary[@"name"] = self.name;
  for (InputCategory *category in self.categories.allValues) {
    [jsonCategoryArray addObject:[category createJson]];
  }
  jsonGroupDictionary[@"categories"] = jsonCategoryArray;
  
  return jsonGroupDictionary;
}

@end
