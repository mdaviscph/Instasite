//
//  JsonData.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "JsonData.h"
#import "TemplateData.h"
#import "Feature.h"

static NSString *const kJsonTemplatesKey = @"templates";
static NSString *const kJsonTitleKey = @"title";
static NSString *const kJsonSubtitleKey = @"subtitle";
static NSString *const kJsonFeaturesKey = @"features";
static NSString *const kJsonHeadlineKey = @"headline";
static NSString *const kJsonSubheadlineKey = @"subheadline";
static NSString *const kJsonBodyKey = @"body";
static NSString *const kJsonImageSrcKey = @"imageSrc";
static NSString *const kJsonCopyrightKey = @"copyright";

@implementation JsonData

+ (NSData *)fromTemplateData:(TemplateData *)templateData {
  
  if (!templateData) {
    return nil;
  }
  
  NSMutableArray *featuresArray = [[NSMutableArray alloc] init];
  for (Feature *feature in templateData.features) {
    NSMutableDictionary *featureDict = [[NSMutableDictionary alloc] init];
    featureDict[kJsonHeadlineKey] = feature.headline;
    featureDict[kJsonSubheadlineKey] = feature.subheadline;
    featureDict[kJsonBodyKey] = feature.body;
    featureDict[kJsonImageSrcKey] = feature.imageSrc;
    [featuresArray addObject:featureDict];
  }
  
  NSMutableDictionary *templateDict = [[NSMutableDictionary alloc] init];
  templateDict[kJsonTitleKey] = templateData.title;
  templateDict[kJsonSubtitleKey] = templateData.subtitle;
  templateDict[kJsonCopyrightKey] = templateData.copyright;
  templateDict[kJsonFeaturesKey] = featuresArray;
  
  NSArray *templatesArray = @[templateDict];
  NSDictionary *rootDict = @{kJsonTemplatesKey : templatesArray};
  
  NSError *error;
  NSData* data = [NSJSONSerialization dataWithJSONObject:rootDict options:NSJSONWritingPrettyPrinted error:&error];
  if (error) {
    NSLog(@"NSJSONSerialization:dataWithJSONObject: error: %@", error.localizedDescription);
    //[AlertPopover alert: kErrorJSONSerialization withNSError: error controller: nil completion: nil];
  }
  return data;
}

+ (TemplateData *)templateDataFrom:(NSData *)data {
  
  if (!data) {
    return nil;
  }

  TemplateData *templateData = [[TemplateData alloc] init];

  NSError *error;
  NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
  if (error) {
    NSLog(@"NSJSONSerialization:JSONObjectWithData: error: %@", error.localizedDescription);
    //[AlertPopover alert: kErrorJSONSerialization withNSError: error controller: nil completion: nil];
  }

  NSArray *templatesArray = rootDictionary[kJsonTemplatesKey];
  NSDictionary *templateDict = templatesArray.firstObject;
  templateData.title = templateDict[kJsonTitleKey];
  templateData.subtitle = templateDict[kJsonSubtitleKey];
  templateData.copyright = templateDict[kJsonCopyrightKey];
  
  NSArray *featuresArray = templateDict[kJsonFeaturesKey];
  templateData.features = [[NSArray alloc] init];
  for (NSDictionary *featureDict in featuresArray) {
    Feature *feature = [[Feature alloc] init];
    feature.headline = featureDict[kJsonHeadlineKey];
    feature.subheadline = featureDict[kJsonSubheadlineKey];
    feature.body = featureDict[kJsonBodyKey];
    feature.imageSrc = featureDict[kJsonImageSrcKey];
  }
  return templateData;
}

@end
