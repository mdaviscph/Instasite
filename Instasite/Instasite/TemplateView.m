//
//  TemplateView.m
//  Instasite
//
//  Created by mike davis on 11/8/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateView.h"

@interface TemplateView ()

@property (strong, readwrite, nonatomic) NSString *name;
@property (strong, readwrite, nonatomic) UIImage *image;
@property (strong, readwrite, nonatomic) NSString *title;

@end

@implementation TemplateView

- (instancetype)initWithName:(NSString *)name title:(NSString *)title image:(UIImage *)image {
  self = [super init];
  if (self) {
    _name = name;
    _image = image;
    _title = title;
  }
  return self;
}

@end
