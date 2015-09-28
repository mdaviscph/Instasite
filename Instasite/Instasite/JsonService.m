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
static NSString *const kJsonFeaturesKey = @"features";
static NSString *const kJsonHeadlineKey = @"headline";
static NSString *const kJsonSubheadlineKey = @"subheadline";
static NSString *const kJsonBodyKey = @"body";
static NSString *const kJsonImageSrcKey = @"imageSrc";
static NSString *const kJsonCopyrightKey = @"copyright";

@implementation JsonService

+ (NSData *)fromTemplateInput:(TemplateInput *)templateInput {
  
  if (!templateInput) {
    return nil;
  }
  
  NSMutableArray *featuresArray = [[NSMutableArray alloc] init];
  for (Feature *feature in templateInput.features) {
    NSMutableDictionary *featureDict = [[NSMutableDictionary alloc] init];
    featureDict[kJsonHeadlineKey] = feature.headline;
    featureDict[kJsonSubheadlineKey] = feature.subheadline;
    featureDict[kJsonBodyKey] = feature.body;
    featureDict[kJsonImageSrcKey] = feature.imageSrc;
    [featuresArray addObject:featureDict];
  }
  
  NSMutableDictionary *templateDict = [[NSMutableDictionary alloc] init];
  templateDict[kJsonTitleKey] = templateInput.title;
  templateDict[kJsonSubtitleKey] = templateInput.subtitle;
  templateDict[kJsonSummaryKey] = templateInput.summary;
  templateDict[kJsonCopyrightKey] = templateInput.copyright;
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
    feature.imageSrc = featureDict[kJsonImageSrcKey];
    [features addObject:feature];
  }
  templateInput.features = features;
  return templateInput;
}

+ (BOOL)writeJsonFile:(NSData *)data filename:(NSString *)filename type:(NSString *)type directory:(NSString *)directory {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *workingDirectory = [documentsPath stringByAppendingPathComponent:directory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:filename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:type];
  
  NSLog(@"Write file: %@", pathWithType);
  if ([[NSFileManager defaultManager] createFileAtPath:pathWithType contents:data attributes:nil]) {
    return YES;
  }
  NSLog(@"Error! Cannot create file: %@ type: %@ in directory %@", filename, type, directory);
  return NO;
}

+ (NSData *)readJsonFile:(NSString *)filename type:(NSString *)type directory:(NSString *)directory {
  
  // TODO - get some identifier for the user to use as filename or part of filename
  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *workingDirectory = [documentsPath stringByAppendingPathComponent:directory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:filename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:type];
  
  NSLog(@"Attempt to read file: %@", pathWithType);
  return [[NSFileManager defaultManager] contentsAtPath:pathWithType];
}

@end
