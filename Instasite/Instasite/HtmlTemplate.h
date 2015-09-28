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
extern NSString *const kMarkerImageSrc;
extern NSString *const kFeatureArray;


// Very basic HTML template support. Initial version not efficient, see comment in .m file.

@interface HtmlTemplate : NSObject

- (instancetype)initWithPath:(NSString *)path ofType:(NSString *)type inDirectory:(NSString *)directory;
+ (NSURL *)genURL: (NSString *)path ofType:(NSString *)type inDirectory:(NSString *)directory;
- (BOOL)writeToFile:(NSString *)path ofType:(NSString *)type inDirectory:(NSString *)directory;

- (void)insertTitle:(NSString *)title;
- (void)insertSubtitle:(NSString *)subtitle;
- (void)insertSummary:(NSString *)summary;
- (void)insertFeature:(HtmlTemplatePlacement)place headline:(NSString *)headline;
- (void)insertFeature:(HtmlTemplatePlacement)place subheadline:(NSString *)subhead;
- (void)insertFeature:(HtmlTemplatePlacement)place body:(NSString *)body;
- (void)insertImageReference:(HtmlTemplatePlacement)place imageSource:(NSString *)imageSrc;
- (void)insertCopyright:(NSString *)copyright;

- (NSString *)html;

- (NSDictionary *)templateMarkers;

@end
