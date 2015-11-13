//
//  TemplateView.h
//  Instasite
//
//  Created by mike davis on 11/8/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface TemplateView : NSObject

@property (strong, readonly, nonatomic) NSString *name;
@property (strong, readonly, nonatomic) UIImage *image;
@property (strong, readonly, nonatomic) NSString *title;

- (instancetype)initWithName:(NSString *)name title:(NSString *)title image:(UIImage *)image;

@end
