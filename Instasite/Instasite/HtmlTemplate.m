//
//  HtmlTemplate.m
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "HtmlTemplate.h"

static NSString *const kMarkerTitle1     = @"INSTASITE-TITLE-1";
static NSString *const kMarkerSubtitle1  = @"INSTASITE-SUBTITLE-1";

static NSString *const kMarkerHead1      = @"INSTASITE-HEAD-1";
static NSString *const kMarkerSub1       = @"INSTASITE-SUB-1";
static NSString *const kMarkerBody1      = @"INSTASITE-BODY-1";
static NSString *const kMarkerImage1     = @"INSTASITE-IMAGE-1";

static NSString *const kMarkerHead2      = @"INSTASITE-HEAD-2";
static NSString *const kMarkerSub2       = @"INSTASITE-SUB-2";
static NSString *const kMarkerBody2      = @"INSTASITE-BODY-2";
static NSString *const kMarkerImage2     = @"INSTASITE-IMAGE-2";

static NSString *const kMarkerHead3      = @"INSTASITE-HEAD-3";
static NSString *const kMarkerSub3       = @"INSTASITE-SUB-3";
static NSString *const kMarkerBody3      = @"INSTASITE-BODY-3";
static NSString *const kMarkerImage3     = @"INSTASITE-IMAGE-3";

static NSString *const kMarkerHead4      = @"INSTASITE-HEAD-4";
static NSString *const kMarkerSub4       = @"INSTASITE-SUB-4";
static NSString *const kMarkerBody4      = @"INSTASITE-BODY-4";
static NSString *const kMarkerImage4     = @"INSTASITE-IMAGE-4";

static NSString *const kMarkerHead5      = @"INSTASITE-HEAD-5";
static NSString *const kMarkerSub5       = @"INSTASITE-SUB-5";
static NSString *const kMarkerBody5      = @"INSTASITE-BODY-5";
static NSString *const kMarkerImage5     = @"INSTASITE-IMAGE-5";

static NSString *const kMarkerCopyRight1 = @"INSTASITE-COPYRIGHT-1";


@interface HtmlTemplate ()

@property (strong, nonatomic) NSString *htmlSource;

@end

@implementation HtmlTemplate

- (instancetype)initWithPath:(NSString *)path ofType:(NSString *)type {
    self = [super init];
    if (self) {
      NSString *documentPath = [[NSBundle mainBundle] pathForResource:path ofType:type];
      NSError *error;
      _htmlSource = [NSString stringWithContentsOfFile:documentPath encoding: NSASCIIStringEncoding error:&error];
      if (error) {
        return nil;
      }
    }
    return self;
}

// TODO - in a future version we should build a dictionary of requested replacements so that we can be more efficient about this process by searching for instances of INSTASITE and after finding an instance we will look up the matching entry in the dictionary and perform the replacement.

- (void)insertTitle:(NSString *)title withSubtitle:(NSString *)subtitle {
  if (title) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerTitle1 withString:title];
  }
  if (subtitle) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerSubtitle1 withString:subtitle];
  }
}
- (void)insertFeature:(HtmlTemplatePlacement)place headline:(NSString *)headline subheadline:(NSString *)subhead body:(NSString *)body {

  NSString *headlineMarker;
  NSString *subheadMarker;
  NSString *bodyMarker;
  
  switch (place) {
    case HtmlPlaceOne:
      headlineMarker = kMarkerHead1;
      subheadMarker = kMarkerSub1;
      bodyMarker = kMarkerBody1;
      break;
    case HtmlPlaceTwo:
      headlineMarker = kMarkerHead2;
      subheadMarker = kMarkerSub2;
      bodyMarker = kMarkerBody2;
      break;
    case HtmlPlaceThree:
      headlineMarker = kMarkerHead3;
      subheadMarker = kMarkerSub3;
      bodyMarker = kMarkerBody3;
      break;
    case HtmlPlaceFour:
      headlineMarker = kMarkerHead4;
      subheadMarker = kMarkerSub4;
      bodyMarker = kMarkerBody4;
      break;
    case HtmlPlaceFive:
      headlineMarker = kMarkerHead5;
      subheadMarker = kMarkerSub5;
      bodyMarker = kMarkerBody5;
      break;
  }

  if (headline) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:headlineMarker withString:headline];
  }
  if (subhead) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:subheadMarker withString:subhead];
  }
  if (body) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:bodyMarker withString:body];
  }
}

- (void)insertImageReference:(HtmlTemplatePlacement)place imageSource:(NSString *)imageSrc {
  
  NSString *imageSrcMarker;
  
  switch (place) {
    case HtmlPlaceOne:
      imageSrcMarker = kMarkerImage1;
      break;
    case HtmlPlaceTwo:
      imageSrcMarker = kMarkerImage2;
      break;
    case HtmlPlaceThree:
      imageSrcMarker = kMarkerImage3;
      break;
    case HtmlPlaceFour:
      imageSrcMarker = kMarkerImage4;
      break;
    case HtmlPlaceFive:
      imageSrcMarker = kMarkerImage5;
      break;
  }
  if (imageSrc) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:imageSrcMarker withString:imageSrc];
  }
}

- (void)insertCopyright:(NSString *)copyright {
  if (copyright) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerCopyRight1 withString:copyright];
  }
}

- (NSString *)html {
  return self.htmlSource;
}
@end
