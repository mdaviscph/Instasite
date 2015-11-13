//
//  TemplateCellDelegate.h
//  Instasite
//
//  Created by mike davis on 11/9/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TemplateCell;

@protocol TemplateCellDelegate <NSObject>

- (void)templateCell:(TemplateCell *)templateCell didSelectItemWithName:(NSString *)name;

@end

