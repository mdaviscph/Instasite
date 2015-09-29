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

@property (strong, nonatomic) NSString *originalHtml;
@property (strong, nonatomic) NSString *modifiedHtml;

@end

@implementation HtmlTemplate

- (instancetype)initWithURL:(NSURL *)htmlURL {
    self = [super init];
    if (self) {
      NSError *error;
      _originalHtml = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
      if (error) {
        NSLog(@"Error! NSString:stringWithContentsOfURL: %@", error.localizedDescription);
        return nil;
      }
      _modifiedHtml = _originalHtml;
    }
    return self;
}

+ (NSURL *)fileURL:(NSString *)filename type:(NSString *)type templateDirectory:(NSString *)templateDirectory documentsDirectory:(NSString *)documentsDirectory {

  NSString *workingDirectory = [documentsDirectory stringByAppendingPathComponent:templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:filename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:type];

  NSURL *url = [NSURL fileURLWithPath:pathWithType];
  if (!url) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return url;
}

- (void)resetToOriginal {
  self.modifiedHtml = self.originalHtml;
}

- (BOOL)writeToURL:(NSURL *)htmlURL {

  NSData *data = [self.modifiedHtml dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) {
    NSLog(@"Error! NSData:dataUsingEncoding: [%@]", htmlURL.relativeString);
    return NO;
  }
  NSLog(@"Writing file: [%@]", htmlURL.relativeString);
  NSError *error;
  [data writeToURL:htmlURL options:NSDataWritingAtomic error:&error];
  if (error) {
    NSLog(@"Error! NSData:writeToURL: %@", error.localizedDescription);
    return NO;
  }
  return YES;
}

// TODO - in a future version we should build a dictionary of requested replacements so that we can be more efficient about this process by searching for instances of INSTASITE and after finding an instance we will look up the matching entry in the dictionary and perform the replacement.

- (void)insertTitle:(NSString *)title {
  if (title) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:kMarkerTitle1 withString:title];
  }
}
- (void)insertSubtitle:(NSString *)subtitle {
  if (subtitle) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:kMarkerSubtitle1 withString:subtitle];
  }
}
- (void)insertSummary:(NSString *)summary {
  if (summary) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:kMarkerSummary1 withString:summary];
  }
}
- (void)insertFeature:(HtmlTemplatePlacement)place headline:(NSString *)headline {

  NSString *headlineMarker;
  switch (place) {
    case HtmlPlaceOne:
      headlineMarker = kMarkerHead1;
      break;
    case HtmlPlaceTwo:
      headlineMarker = kMarkerHead2;
      break;
    case HtmlPlaceThree:
      headlineMarker = kMarkerHead3;
      break;
    case HtmlPlaceFour:
      headlineMarker = kMarkerHead4;
      break;
    case HtmlPlaceFive:
      headlineMarker = kMarkerHead5;
      break;
  }
  if (headline) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:headlineMarker withString:headline];
  }
}
- (void)insertFeature:(HtmlTemplatePlacement)place subheadline:(NSString *)subhead {

  NSString *subheadMarker;
  switch (place) {
    case HtmlPlaceOne:
      subheadMarker = kMarkerSub1;
      break;
    case HtmlPlaceTwo:
      subheadMarker = kMarkerSub2;
      break;
    case HtmlPlaceThree:
      subheadMarker = kMarkerSub3;
      break;
    case HtmlPlaceFour:
      subheadMarker = kMarkerSub4;
      break;
    case HtmlPlaceFive:
      subheadMarker = kMarkerSub5;
      break;
  }
  if (subhead) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:subheadMarker withString:subhead];
  }
}
- (void)insertFeature:(HtmlTemplatePlacement)place body:(NSString *)body {

  NSString *bodyMarker;
  switch (place) {
    case HtmlPlaceOne:
      bodyMarker = kMarkerBody1;
      break;
    case HtmlPlaceTwo:
      bodyMarker = kMarkerBody2;
      break;
    case HtmlPlaceThree:
      bodyMarker = kMarkerBody3;
      break;
    case HtmlPlaceFour:
      bodyMarker = kMarkerBody4;
      break;
    case HtmlPlaceFive:
      bodyMarker = kMarkerBody5;
      break;
  }
  if (body) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:bodyMarker withString:body];
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
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:imageSrcMarker withString:imageSrc];
  }
}

- (void)insertCopyright:(NSString *)copyright {
  if (copyright) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:kMarkerCopyRight1 withString:copyright];
  }
}

- (NSString *)html {
  return self.modifiedHtml;
}

- (NSDictionary *)templateMarkers {
  
  NSUInteger titleCount = 0;
  NSUInteger subtitleCount = 0;
  NSUInteger summaryCount = 0;
  NSUInteger copyrightCount = 0;
  
  NSArray *features = @[[[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init], [[NSMutableDictionary alloc] init]];
  
  NSMutableDictionary *markerDict = [[NSMutableDictionary alloc] init];
  
  NSArray *components = [self.modifiedHtml componentsSeparatedByString:kMarkerBase];
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
