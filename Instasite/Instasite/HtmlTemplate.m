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
NSString *const kImageRefArray       = @"IMAGES";


// TODO - do away with these by looking for all tags starting with kMarkerBase, possibly using regular expression
static NSString *const kMarkerTitle1        = @"INSTASITE-TITLE-01";
static NSString *const kMarkerSubtitle1     = @"INSTASITE-SUBTITLE-01";
static NSString *const kMarkerSummary1      = @"INSTASITE-SUMMARY-01";
static NSString *const kMarkerCopyRight1    = @"INSTASITE-COPYRIGHT-01";

static NSString *const kMarkerHead1         = @"INSTASITE-HEAD-01";
static NSString *const kMarkerSub1          = @"INSTASITE-SUB-01";
static NSString *const kMarkerBody1         = @"INSTASITE-BODY-01";

static NSString *const kMarkerHead2         = @"INSTASITE-HEAD-02";
static NSString *const kMarkerSub2          = @"INSTASITE-SUB-02";
static NSString *const kMarkerBody2         = @"INSTASITE-BODY-02";

static NSString *const kMarkerHead3         = @"INSTASITE-HEAD-03";
static NSString *const kMarkerSub3          = @"INSTASITE-HEAD-03";
static NSString *const kMarkerBody3         = @"INSTASITE-BODY-03";

static NSString *const kMarkerHead4         = @"INSTASITE-HEAD-04";
static NSString *const kMarkerSub4          = @"INSTASITE-SUB-04";
static NSString *const kMarkerBody4         = @"INSTASITE-BODY-04";

static NSString *const kMarkerHead5         = @"INSTASITE-HEAD-05";
static NSString *const kMarkerSub5          = @"INSTASITE-SUB-05";
static NSString *const kMarkerBody5         = @"INSTASITE-BODY-05";

static NSString *const kMarkerImageSrc1     = @"INSTASITE-IMAGE-01";
static NSString *const kMarkerImageSrc2     = @"INSTASITE-IMAGE-02";
static NSString *const kMarkerImageSrc3     = @"INSTASITE-IMAGE-03";
static NSString *const kMarkerImageSrc4     = @"INSTASITE-IMAGE-04";
static NSString *const kMarkerImageSrc5     = @"INSTASITE-IMAGE-05";
static NSString *const kMarkerImageSrc6     = @"INSTASITE-IMAGE-06";
static NSString *const kMarkerImageSrc7     = @"INSTASITE-IMAGE-07";
static NSString *const kMarkerImageSrc8     = @"INSTASITE-IMAGE-08";
static NSString *const kMarkerImageSrc9     = @"INSTASITE-IMAGE-09";

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

- (void)resetToOriginal {
  self.modifiedHtml = self.originalHtml;
}

- (BOOL)writeToURL:(NSURL *)htmlURL {

  NSData *data = [self.modifiedHtml dataUsingEncoding:NSUTF8StringEncoding];
  if (!data) {
    NSLog(@"Error! NSData:dataUsingEncoding: [%@]", htmlURL.relativeString);
    return NO;
  }
  
  //NSLog(@"Writing file: [%@]", htmlURL.relativeString);
  NSError *error;
  [data writeToURL:htmlURL options:NSDataWritingAtomic error:&error];
  if (error) {
    NSLog(@"Error! NSData:writeToURL: [%@] error: %@", htmlURL.relativeString, error.localizedDescription);
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
- (void)insertCopyright:(NSString *)copyright {
  if (copyright) {
    self.modifiedHtml = [self.modifiedHtml stringByReplacingOccurrencesOfString:kMarkerCopyRight1 withString:copyright];
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

- (NSString *)html {
  return self.modifiedHtml;
}

- (NSDictionary *)templateMarkers {
  
  NSUInteger titleCount = 0;
  NSUInteger subtitleCount = 0;
  NSUInteger summaryCount = 0;
  NSUInteger copyrightCount = 0;
  
  NSArray *features;
  NSArray *imageRefs;
  
  NSMutableDictionary *markerDict = [[NSMutableDictionary alloc] init];
  
  NSArray *components = [self.modifiedHtml componentsSeparatedByString:kMarkerBase];
  // skip the first component which is the start of the html
  for (NSInteger index = 1; index < components.count; index++) {
    NSString *component = components[index];
    NSInteger number;
    
    // TODO - refactor this
    if ([component hasPrefix:kMarkerTitle]) {
      number = [self markerNumberFor:kMarkerTitle from:component];
      if (number > 0) {
        titleCount = MAX(titleCount, number);
        markerDict[kMarkerTitle] = @(titleCount);
      }
    } else if ([component hasPrefix:kMarkerSubtitle]) {
      number = [self markerNumberFor:kMarkerSubtitle from:component];
      if (number > 0) {
        subtitleCount = MAX(subtitleCount, number);
        markerDict[kMarkerSubtitle] = @(subtitleCount);
      }
    } else if ([component hasPrefix:kMarkerSummary]) {
      number = [self markerNumberFor:kMarkerSummary from:component];
      if (number > 0) {
        summaryCount = MAX(summaryCount, number);
        markerDict[kMarkerSummary] = @(summaryCount);
      }
    } else if ([component hasPrefix:kMarkerCopyright]) {
      number = [self markerNumberFor:kMarkerCopyright from:component];
      if (number > 0) {
        copyrightCount = MAX(copyrightCount, number);
        markerDict[kMarkerCopyright] = @(copyrightCount);
      }
      
    } else if ([component hasPrefix:kMarkerImageSrc]) {
      number = [self markerNumberFor:kMarkerImageSrc from:component];
      if (number >= 0) {
        imageRefs = [self appendDictionaryToArray:imageRefs toIndex:number-1];
        imageRefs[number-1][kMarkerImageSrc] = @(1);
      }
    
    } else if ([component hasPrefix:kMarkerHead]) {
      number = [self markerNumberFor:kMarkerHead from:component];
      if (number >= 0) {
        features = [self appendDictionaryToArray:features toIndex:number-1];
        features[number-1][kMarkerHead] = @(1);
      }
    } else if ([component hasPrefix:kMarkerSub]) {
      number = [self markerNumberFor:kMarkerSub from:component];
      if (number >= 0) {
        features = [self appendDictionaryToArray:features toIndex:number-1];
        features[number-1][kMarkerSub] = @(1);
      }
    } else if ([component hasPrefix:kMarkerBody]) {
      number = [self markerNumberFor:kMarkerBody from:component];
      if (number >= 0) {
        features = [self appendDictionaryToArray:features toIndex:number-1];
        features[number-1][kMarkerBody] = @(1);
      }
    }
  }
  
  markerDict[kFeatureArray] = features;
  markerDict[kImageRefArray] = imageRefs;
  return markerDict;
}

- (NSInteger)markerNumberFor:(NSString *)marker from:(NSString *)string {
  
  NSRange range = NSMakeRange(marker.length, 2);    // limits support of upto 99 of each type of marker
  NSInteger number = [string substringWithRange:range].integerValue;
  
  return number;
}

- (NSArray *)appendDictionaryToArray:(NSArray *)array toIndex:(NSUInteger)index {
  
  NSMutableArray *copyWithAdditions = [[NSMutableArray alloc] initWithArray:array];
  for (NSUInteger another = array.count; another <= index; another++) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [copyWithAdditions addObject:dictionary];
  }
  return copyWithAdditions;
}
@end
