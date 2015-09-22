//
//  HtmlTemplate.h
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

enum HtmlTemplatePlacement {
  HtmlPlaceOne,
  HtmlPlaceTwo,
  HtmlPlaceThree,
  HtmlPlaceFour,
  HtmlPlaceFive
};
typedef enum HtmlTemplatePlacement HtmlTemplatePlacement;

// Very basic HTML template support. Initial version not efficient, see comment in .m file.

@interface HtmlTemplate : NSObject

- (instancetype)initWithPath:(NSString *)path ofType:(NSString *)type;

- (void)insertTitle:(NSString *)title withSubtitle:(NSString *)subtitle;
- (void)insertFeature:(HtmlTemplatePlacement)place headline:(NSString *)headline subheadline:(NSString *)subhead body:(NSString *)body;
- (void)insertImageReference:(HtmlTemplatePlacement)place imageSource:(NSString *)imageSrc;
- (void)insertCopyright:(NSString *)copyright;

- (NSString *)html;

@end
