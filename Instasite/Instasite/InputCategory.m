//
//  InputCategory.m
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "InputCategory.h"
#import "InputField.h"
#import "TemplateField.h"

@implementation InputCategory

- (instancetype)initFromTemplateField:(TemplateField *)templateField {
  self = [super init];
  if (self) {
    _name = templateField.categoryName;
    _fields = [[InputFieldDictionary alloc] init];
  }
  return self;
}

- (BOOL)setFieldText:(NSString *)text forTag:(NSInteger)tag {
  for (InputField *field in self.fields.allValues) {
    if (field.tag == tag) {
      field.text = text.length > 0 ? text : nil;
      return YES;
    }
  }
  return NO;
}

@end
