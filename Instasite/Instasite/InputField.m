//
//  InputField.m
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "InputField.h"
#import "TemplateField.h"

@implementation InputField

- (instancetype)initFromTemplateField:(TemplateField *)templateField {
  self = [super init];
  if (self) {
    _name = templateField.fieldName;
    if      ([templateField.fieldType isEqualToString:@"TXF"]) { _type = FieldTXF; }
    else if ([templateField.fieldType isEqualToString:@"TXV"]) { _type = FieldTXV; }
    else if ([templateField.fieldType isEqualToString:@"IMG"]) { _type = FieldIMG; }
    _placeholder = templateField.fieldPlaceholder;
    _regEx = templateField.fieldRegEx;
  }
  return self;
}

@end
