//
//  JsonService.m
//  Instasite
//
//  Created by mike davis on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "JsonService.h"
#import "TemplateInput.h"
#import "Feature.h"

static NSString *const kJsonTemplatesKey = @"templates";
static NSString *const kJsonTitleKey = @"title";
static NSString *const kJsonSubtitleKey = @"subtitle";
static NSString *const kJsonSummaryKey = @"summary";
static NSString *const kJsonCopyrightKey = @"copyright";
static NSString *const kJsonFeaturesKey = @"features";
static NSString *const kJsonHeadlineKey = @"headline";
static NSString *const kJsonSubheadlineKey = @"subheadline";
static NSString *const kJsonBodyKey = @"body";
static NSString *const kJsonImagesKey = @"images";
static NSString *const kJsonImageSrcKey = @"imageSrc";

@implementation JsonService

+ (NSData *)fromTemplateInput:(TemplateInput *)templateInput {
  
  if (!templateInput) {
    return nil;
  }

  NSMutableArray *imageRefsArray = [[NSMutableArray alloc] init];
  for (NSString *imageRef in templateInput.imageRefs) {
    NSMutableDictionary *imageRefDict = [[NSMutableDictionary alloc] init];
    imageRefDict[kJsonImageSrcKey] = imageRef;
    [imageRefsArray addObject:imageRefDict];
  }
  
  NSMutableArray *featuresArray = [[NSMutableArray alloc] init];
  for (Feature *feature in templateInput.features) {
    NSMutableDictionary *featureDict = [[NSMutableDictionary alloc] init];
    featureDict[kJsonHeadlineKey] = feature.headline;
    featureDict[kJsonSubheadlineKey] = feature.subheadline;
    featureDict[kJsonBodyKey] = feature.body;
    [featuresArray addObject:featureDict];
  }
  
  NSMutableDictionary *templateDict = [[NSMutableDictionary alloc] init];
  templateDict[kJsonTitleKey] = templateInput.title;
  templateDict[kJsonSubtitleKey] = templateInput.subtitle;
  templateDict[kJsonSummaryKey] = templateInput.summary;
  templateDict[kJsonCopyrightKey] = templateInput.copyright;
  templateDict[kJsonFeaturesKey] = featuresArray;
  templateDict[kJsonImagesKey] = imageRefsArray;
  
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

+ (TemplateInput *)templateInputFrom:(NSData *)data {
  
  if (!data) {
    return nil;
  }

  TemplateInput *templateInput = [[TemplateInput alloc] init];

  NSError *error;
  NSDictionary *rootDictionary = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
  if (error) {
    NSLog(@"NSJSONSerialization:JSONObjectWithData: error: %@", error.localizedDescription);
    //[AlertPopover alert: kErrorJSONSerialization withNSError: error controller: nil completion: nil];
  }

  NSArray *templatesArray = rootDictionary[kJsonTemplatesKey];
  NSDictionary *templateDict = templatesArray.firstObject;
  templateInput.title = templateDict[kJsonTitleKey];
  templateInput.subtitle = templateDict[kJsonSubtitleKey];
  templateInput.summary = templateDict[kJsonSummaryKey];
  templateInput.copyright = templateDict[kJsonCopyrightKey];
  
  NSArray *featuresArray = templateDict[kJsonFeaturesKey];
  NSMutableArray *features = [[NSMutableArray alloc] init];
  for (NSDictionary *featureDict in featuresArray) {
    Feature *feature = [[Feature alloc] init];
    feature.headline = featureDict[kJsonHeadlineKey];
    feature.subheadline = featureDict[kJsonSubheadlineKey];
    feature.body = featureDict[kJsonBodyKey];
    [features addObject:feature];
  }
  templateInput.features = features;
  
  NSArray *imageRefsArray = templateDict[kJsonImagesKey];
  NSMutableArray *imageRefs = [[NSMutableArray alloc] init];
  for (NSDictionary *imageRefDict in imageRefsArray) {
    [imageRefs addObject:imageRefDict[kJsonImageSrcKey]];
  }
  templateInput.imageRefs = imageRefs;

  return templateInput;
}

+ (BOOL)writeJsonFile:(NSData *)data fileURL:(NSURL *)fileURL {

  NSLog(@"Writing file: %@", fileURL.relativePath);

  NSError *error;
  [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];

  if (error) {
    NSLog(@"Error! NSData:writeToURL: [%@] error: %@", fileURL.relativeString, error.localizedDescription);
    return NO;
  }
  return YES;
}

+ (NSData *)readJsonFile:(NSURL *)fileURL {
  
  NSLog(@"Reading file: %@", fileURL.relativePath);
  
  NSError *error;
  NSData *jsonFile = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingUncached error:&error];
  if (error) {
    NSLog(@"Error! NSData:dataWithContentsOfFile: [%@] error: %@", fileURL, error.localizedDescription);
    return nil;
  }
  
  return jsonFile;
}

@end
