//
//  TemplateCell.h
//  Instasite
//
//  Created by mike davis on 11/8/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateCellIDelegate.h"
#import <UIKit/UIKit.h>

@class TemplateView;

@interface TemplateCell : UITableViewCell

@property (strong, nonatomic) NSArray<TemplateView *> *templates;

@property (weak, nonatomic) id<TemplateCellDelegate> delegate;

@end
