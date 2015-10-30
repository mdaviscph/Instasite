//
//  TemplateField.h
//  Instasite
//
//  Created by mike davis on 10/29/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateField : NSObject

@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *fieldName;
@property (strong, nonatomic) NSString *fieldType;
@property (strong, nonatomic) NSString *fieldPlaceholder;
@property (strong, nonatomic) NSString *fieldRegEx;

- (instancetype)initFromCsv:(NSString *)csv;

@end
