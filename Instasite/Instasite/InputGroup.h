//
//  InputGroup.h
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class TemplateField;

@interface InputGroup : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) InputCategoryDictionary *categories;
@property (nonatomic) NSInteger tag;

- (instancetype)initFromTemplateField:(TemplateField *)templateField;

@end
