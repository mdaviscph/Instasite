//
//  InputCategory.h
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class TemplateField;

@interface InputCategory : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) InputFieldDictionary *fields;
@property (nonatomic) NSInteger tag;

- (instancetype)initFromTemplateField:(TemplateField *)templateField;
- (BOOL)setFieldText:(NSString *)text forTag:(NSInteger)tag;

@end
