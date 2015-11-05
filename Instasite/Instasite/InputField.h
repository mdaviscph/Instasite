//
//  InputField.h
//  Instasite
//
//  Created by mike davis on 10/28/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeDefsEnums.h"

@class TemplateField;

@interface InputField : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) TemplateFieldType type;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *regEx;
@property (nonatomic) NSInteger tag;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSData *data;

- (instancetype)initFromTemplateField:(TemplateField *)templateField;
  
@end
