//
//  TemplateField.m
//  Instasite
//
//  Created by mike davis on 10/29/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateField.h"

@implementation TemplateField

- (instancetype)initFromCsv:(NSString *)csv {
  self = [super init];
  if (self) {

    NSArray *components = [csv componentsSeparatedByString:@","];     // TODO - figure out how to escape commas
    if (components.count == 6) {                                      // TODO - have last two values be optional
      _groupName        = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      _categoryName     = [components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      _fieldName        = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      _fieldType        = [components[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      _fieldPlaceholder = [components[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      _fieldRegEx       = [components[5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
      return nil;
    }
  }
  return self;
}

@end
