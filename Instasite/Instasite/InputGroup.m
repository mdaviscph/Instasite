//
//  InputGroup.m
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "InputGroup.h"
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

@end
