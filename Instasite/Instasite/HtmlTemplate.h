//
//  HtmlTemplate.h
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>

enum HtmlTemplatePlacement: NSInteger {
  HtmlPlaceOne = 0,
  HtmlPlaceTwo,
  HtmlPlaceThree,
  HtmlPlaceFour,
  HtmlPlaceFive
};
typedef enum HtmlTemplatePlacement HtmlTemplatePlacement;

enum HtmlMarkerTextEdit: NSInteger {
  HtmlMarkerTitle = 1,
  HtmlMarkerSubtitle,
  HtmlMarkerSummary,
  HtmlMarkerCopyright,
  HtmlMarkerTextEditStartOfFeature, // this is not a marker type but an indicator to use when assigning next responder
  HtmlMarkerHeadline,
  HtmlMarkerSubheadline,
  HtmlMarkerBody,
  HtmlMarkerTextEditEndOfFeature    // this is not a marker type but an indicator to use when assigning next responder
};
typedef enum HtmlMarkerTextEdit HtmlMarkerTextEdit;

extern NSString *const kMarkerBase;

extern NSString *const kMarkerTitle;
extern NSString *const kMarkerSubtitle;
extern NSString *const kMarkerSummary;
extern NSString *const kMarkerCopyright;
extern NSString *const kMarkerHead;
extern NSString *const kMarkerSub;
extern NSString *const kMarkerBody;

extern NSString *const kFeatureArray;
extern NSString *const kImageRefArray;

// Very basic HTML template support. Initial version not efficient, see comment in .m file.

@interface HtmlTemplate : NSObject

- (instancetype)initWithURL:(NSURL *)htmlURL;
- (void)resetToOriginal;

- (BOOL)writeToURL:(NSURL *)htmlURL;

- (void)insertTitle:(NSString *)title;
- (void)insertSubtitle:(NSString *)subtitle;
- (void)insertSummary:(NSString *)summary;
- (void)insertCopyright:(NSString *)copyright;

- (void)insertFeature:(HtmlTemplatePlacement)place headline:(NSString *)headline;
- (void)insertFeature:(HtmlTemplatePlacement)place subheadline:(NSString *)subhead;
- (void)insertFeature:(HtmlTemplatePlacement)place body:(NSString *)body;

- (void)insertImageReference:(NSString *)marker imageSource:(NSString *)imageSrc;

- (NSString *)html;

- (NSDictionary *)templateMarkers;

@end
