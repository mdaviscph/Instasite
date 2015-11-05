//
//  HtmlTemplate.m
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "HtmlTemplate.h"
#import "TemplateField.h"
#import "UserInput.h"
#import "InputGroup.h"
#import "InputCategory.h"
#import "InputField.h"
#import "Extensions.h"

static NSString *const kMarkerField = @"INSTASITE-FIELD";

@interface HtmlTemplate ()

@property (strong, readwrite, nonatomic) NSString *html;

@end

@implementation HtmlTemplate

- (instancetype)initWithURL:(NSURL *)htmlURL {
    self = [super init];
    if (self) {
      NSError *error;
      _html = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
      if (error) {
        NSLog(@"Error! NSString:stringWithContentsOfURL: %@", error.localizedDescription);
        return nil;
      }
    }
    return self;
}

- (NSString *)replaceFieldMarkers:(NSString *)original usingInputGroups:(InputGroupDictionary *)groups {
  
  NSMutableString *modifiedHtml = [[NSMutableString alloc] init];
  NSArray *components = [self.html componentsSeparatedByString:kMarkerField];

  // copy the first component which is the start of the html
  [modifiedHtml appendString:components[0]];
  for (NSInteger index = 1; index < components.count; index++) {
    
    NSString *component = components[index];
    NSArray *inParens = [component componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    [modifiedHtml appendString:inParens[0]];
    
    if (inParens.count < 2) {
      NSLog(@"Error! Invalid Template Field: %@", [component abbreviate:20]);
      return nil;
    }
    
    // parse INSTASITE-FIELD tuple
    TemplateField *templateField = [[TemplateField alloc] initFromCsv:inParens[1]];
    
    InputGroup *group = groups[templateField.groupName];
    InputCategory *category = group.categories[templateField.categoryName];
    InputField *field = category.fields[templateField.fieldName];

    NSString *replacement = field.text ? field.text : field.placeholder;
    [modifiedHtml appendString:replacement];
    
    for (NSInteger remaining = 2; remaining < inParens.count; remaining++) {
      [modifiedHtml appendString:inParens[remaining]];
    }
  }
  
  return modifiedHtml;
}

- (void)addInputGroupsToUserInput:(UserInput *)userInput {
  
  InputGroupMutableDictionary *groups = [[InputGroupMutableDictionary alloc] initWithDictionary:userInput.groups];
  NSInteger groupTag = userInput.maxGroupTag;
  NSInteger categoryTag = userInput.maxCategoryTag;
  NSInteger fieldTag = userInput.maxFieldTag;
  
  NSArray *components = [self.html componentsSeparatedByString:kMarkerField];
  
  for (NSInteger index = 1; index < components.count; index++) {    // skip the first component which is the start of the html
    
    NSString *component = components[index];
    NSArray *inParens = [component componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
    
    if (inParens.count < 2) {
      NSLog(@"Error! Invalid Template Field: %@", [component abbreviate:20]);
      continue;
    }
    // parse INSTASITE-FIELD tuple
    TemplateField *templateField = [[TemplateField alloc] initFromCsv:inParens[1]];
    
    InputGroup *group = groups[templateField.groupName];
    if (!group) {
      group = [[InputGroup alloc] initFromTemplateField:templateField];
      group.tag = ++groupTag;
    }
    InputCategoryMutableDictionary *categories = [[InputCategoryMutableDictionary alloc] initWithDictionary:group.categories];
    InputCategory *category = categories[templateField.categoryName];
    if (!category) {
      category = [[InputCategory alloc] initFromTemplateField:templateField];
      category.tag = ++categoryTag;
    }
    InputFieldMutableDictionary *fields = [[InputFieldMutableDictionary alloc] initWithDictionary:category.fields];
    InputField *field = fields[templateField.fieldName];
    if (field) {
      NSLog(@"Error! Duplicate Template Field: (%@)", inParens[1]);
      continue;
    }
    field = [[InputField alloc] initFromTemplateField:templateField];
    field.tag = ++fieldTag;
    
    fields[templateField.fieldName] = field;
    category.fields = fields;
    categories[templateField.categoryName] = category;
    group.categories = categories;
    groups[templateField.groupName] = group;
  }

  userInput.groups = groups;
  userInput.maxGroupTag = groupTag;
  userInput.maxCategoryTag = categoryTag;
  userInput.maxFieldTag = fieldTag;
}

- (BOOL)writeToURL:(NSURL *)htmlURL withInputGroups:(InputGroupDictionary *)groups {

  NSString *modifiedHtml = groups ? [self replaceFieldMarkers:self.html usingInputGroups:groups] : self.html;
  
  NSData *data = [modifiedHtml dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) {
    NSLog(@"Error! NSData:dataUsingEncoding: [%@]", htmlURL.relativeString);
    return NO;
  }
  
  //NSLog(@"Writing file: [%@]", htmlURL.relativeString);
  NSError *error;
  [data writeToURL:htmlURL options:NSDataWritingAtomic error:&error];
  if (error) {
    NSLog(@"Error! NSData:writeToURL: [%@] error: %@", htmlURL.relativeString, error.localizedDescription);
    return NO;
  }
  return YES;
}

@end
