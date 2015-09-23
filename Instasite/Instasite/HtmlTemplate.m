//
//  HtmlTemplate.m
//  Instasite
//
//  Created by mike davis on 9/21/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "HtmlTemplate.h"

NSString *const kMarkerBase          = @"INSTASITE-";
NSString *const kMarkerTitle         = @"TITLE-";
NSString *const kMarkerSubtitle      = @"SUBTITLE-";
NSString *const kMarkerSummary       = @"SUMMARY-";
NSString *const kMarkerCopyright     = @"COPYRIGHT-";
NSString *const kMarkerHead          = @"HEAD-";
NSString *const kMarkerSub           = @"SUB-";
NSString *const kMarkerBody          = @"BODY-";
NSString *const kMarkerImageSrc      = @"IMAGE-";
NSString *const kFeatureArray        = @"FEATURES";

static NSString *const kMarkerTitle1        = @"INSTASITE-TITLE-1";
static NSString *const kMarkerSubtitle1     = @"INSTASITE-SUBTITLE-1";
static NSString *const kMarkerSummary1      = @"INSTASITE-SUMMARY-1";
static NSString *const kMarkerCopyRight1    = @"INSTASITE-COPYRIGHT-1";

static NSString *const kMarkerHead1         = @"INSTASITE-HEAD-1";
static NSString *const kMarkerSub1          = @"INSTASITE-SUB-1";
static NSString *const kMarkerBody1         = @"INSTASITE-BODY-1";
static NSString *const kMarkerImageSrc1     = @"INSTASITE-IMAGE-1";

static NSString *const kMarkerHead2         = @"INSTASITE-HEAD-2";
static NSString *const kMarkerSub2          = @"INSTASITE-SUB-2";
static NSString *const kMarkerBody2         = @"INSTASITE-BODY-2";
static NSString *const kMarkerImageSrc2     = @"INSTASITE-IMAGE-2";

static NSString *const kMarkerHead3         = @"INSTASITE-HEAD-3";
static NSString *const kMarkerSub3          = @"INSTASITE-HEAD-3";
static NSString *const kMarkerBody3         = @"INSTASITE-BODY-3";
static NSString *const kMarkerImageSrc3     = @"INSTASITE-IMAGE-3";

static NSString *const kMarkerHead4         = @"INSTASITE-HEAD-4";
static NSString *const kMarkerSub4          = @"INSTASITE-SUB-4";
static NSString *const kMarkerBody4         = @"INSTASITE-BODY-4";
static NSString *const kMarkerImageSrc4     = @"INSTASITE-IMAGE-4";

static NSString *const kMarkerHead5         = @"INSTASITE-HEAD-5";
static NSString *const kMarkerSub5          = @"INSTASITE-SUB-5";
static NSString *const kMarkerBody5         = @"INSTASITE-BODY-5";
static NSString *const kMarkerImageSrc5     = @"INSTASITE-IMAGE-5";


// Very basic HTML template support. Initial version not efficient, see comment below.

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

- (void)insertTitle:(NSString *)title withSubtitle:(NSString *)subtitle withSummary:(NSString *)summary {
  if (title) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerTitle1 withString:title];
  }
  if (subtitle) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerSubtitle1 withString:subtitle];
  }
  if (summary) {
    self.htmlSource = [self.htmlSource stringByReplacingOccurrencesOfString:kMarkerSummary1 withString:summary];
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
      imageSrcMarker = kMarkerImageSrc1;
      break;
    case HtmlPlaceTwo:
      imageSrcMarker = kMarkerImageSrc2;
      break;
    case HtmlPlaceThree:
      imageSrcMarker = kMarkerImageSrc3;
      break;
    case HtmlPlaceFour:
      imageSrcMarker = kMarkerImageSrc4;
      break;
    case HtmlPlaceFive:
      imageSrcMarker = kMarkerImageSrc5;
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

- (NSDictionary *)templateMarkers {
  
  NSUInteger titleCount = 0;
  NSUInteger subtitleCount = 0;
  NSUInteger summaryCount = 0;
  NSUInteger copyrightCount = 0;
  
  NSArray *features = @[[[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init]];
  
  NSMutableDictionary *markerDict = [[NSMutableDictionary alloc] init];
  
  NSArray *components = [self.htmlSource componentsSeparatedByString:kMarkerBase];
  // skip the first component which is the start of the html
  for (NSInteger index = 1; index < components.count; index++) {
    NSString *component = components[index];
    
    if ([component hasPrefix:kMarkerTitle]) {
      markerDict[kMarkerTitle] = @(++titleCount);
    } else if ([component hasPrefix:kMarkerSubtitle]) {
      markerDict[kMarkerSubtitle] = @(++subtitleCount);
    } else if ([component hasPrefix:kMarkerSummary]) {
      markerDict[kMarkerSummary] = @(++summaryCount);
    } else if ([component hasPrefix:kMarkerCopyright]) {
      markerDict[kMarkerCopyright] = @(++copyrightCount);
      
    } else if ([component hasPrefix:kMarkerHead]) {
      NSRange range = NSMakeRange(kMarkerHead.length, 1);    // this limits us to single digit number of headlines, etc.
      NSInteger count = [component substringWithRange:range].integerValue - 1;
      if (count >= 0 && count < 5) {
        features[count][kMarkerHead] = @(1);
      }
    } else if ([component hasPrefix:kMarkerSub]) {
      NSRange range = NSMakeRange(kMarkerSub.length, 1);    // this limits us to single digit number of headlines, etc.
      NSInteger count = [component substringWithRange:range].integerValue - 1;
      if (count >= 0 && count < 5) {
        features[count][kMarkerSub] = @(1);
      }
    } else if ([component hasPrefix:kMarkerBody]) {
      NSRange range = NSMakeRange(kMarkerBody.length, 1);    // this limits us to single digit number of headlines, etc.
      NSInteger count = [component substringWithRange:range].integerValue - 1;
      if (count >= 0 && count < 5) {
        features[count][kMarkerBody] = @(1);
      }
    } else if ([component hasPrefix:kMarkerImageSrc]) {
      NSRange range = NSMakeRange(kMarkerImageSrc.length, 1);    // this limits us to single digit number of headlines, etc.
      NSInteger count = [component substringWithRange:range].integerValue - 1;
      if (count >= 0 && count < 5) {
        features[count][kMarkerImageSrc] = @(1);
      }
    }
  }
  
  markerDict[kFeatureArray] = features;
  return markerDict;
}
@end
