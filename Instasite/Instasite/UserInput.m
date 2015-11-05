//
//  UserInput.m
//  Instasite
//
//  Created by mike davis on 10/31/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "UserInput.h"
#import "InputGroup.h"
#import "InputCategory.h"

@implementation UserInput

- (instancetype)init {
  self = [super init];
  if (self) {
    _groups = [[InputGroupDictionary alloc] init];    // starts out as an empty dictionary and will be replaced
  }
  return self;
}

- (NSData *)createJsonData {
  
  NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
  NSMutableArray *jsonGroupArray = [[NSMutableArray alloc] init];
  
  for (InputGroup *group in self.groups.allValues) {
    [jsonGroupArray addObject:[group createJson]];
  }
  jsonDictionary[@"groups"] = jsonGroupArray;
  
  NSError *error;
  NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
  if (error) {
    NSLog(@"NSJSONSerialization:dataWithJSONObject: error: %@", error.localizedDescription);
    // TODO - alert popover?
  }
  
  return jsonData;
}

- (void)updateUsingJsonData:(NSData *)data {
  
  NSError *error;
  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  if (error) {
    NSLog(@"NSJSONSerialization:JSONObjectWithData: error: %@", error.localizedDescription);
    // TODO - alert popover?
  }
  
  NSArray *jsonGroupArray = jsonDictionary[@"groups"];
  for (NSDictionary *jsonGroupDictionary in jsonGroupArray) {
    
    NSString *groupName = jsonGroupDictionary[@"name"];
    NSArray *jsonCategoryArray = jsonGroupDictionary[@"categories"];
    for (NSDictionary *jsonCategoryDictionary in jsonCategoryArray) {
      
      NSString *categoryName = jsonCategoryDictionary[@"name"];
      NSDictionary *fieldDictionary = jsonCategoryDictionary[@"fields"];
      for (NSString *fieldName in fieldDictionary.allKeys) {
        NSString *text = fieldDictionary[fieldName];
        
        InputGroup *group = self.groups[groupName];
        InputCategoryDictionary *categories = group.categories;
        InputCategory *category = categories[categoryName];
        
        [category setFieldText:text forName:fieldName];
      }
    }
  }
}

@end
