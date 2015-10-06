//
//  TemplateTabBarController.m
//  Instasite
//
//  Created by mike davis on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplateTabBarController.h"
#import "HtmlTemplate.h"
#import "Constants.h"
#import "FileManager.h"

@interface TemplateTabBarController ()

@end

@implementation TemplateTabBarController

- (NSURL *)indexHtmlURL {
  if (!_indexHtmlURL) {
    _indexHtmlURL = [self indexFileURL];
  }
  return _indexHtmlURL;
}
- (NSURL *)indexHtmlDirectoryURL {
  if (!_indexHtmlDirectoryURL) {
    _indexHtmlDirectoryURL = [self indexDirectoryURL];
  }
  return _indexHtmlDirectoryURL;
}
- (NSURL *)templateHtmlURL {
  if (!_templateHtmlURL) {
    _templateHtmlURL = [self templateFileURL];
  }
  return _templateHtmlURL;
}
- (NSURL *)userJsonURL {
  if (!_userJsonURL) {
    _userJsonURL = [self jsonFileURL];
  }
  return _userJsonURL;
}

- (NSArray *)images {
  if (!_images) {
    _images = [[NSMutableArray alloc] init];
    [self loadImagesFromFiles];
  }
  return _images;
}

- (HtmlTemplate *)templateCopy {
  if (!_templateCopy) {
    _templateCopy = [[HtmlTemplate alloc] initWithURL:[self templateHtmlURL]];
  }
  return _templateCopy;
}

- (NSDictionary *)templateMarkers {
  if (!_templateMarkers) {
    _templateMarkers = [self.templateCopy templateMarkers];
  }
  return _templateMarkers;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSLog(@"Documents directory: %@", self.documentsDirectory);
  [self copyBundleTemplateDirectory];
}

#pragma mark - Helper Methods

- (NSURL *)indexFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateIndexFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateIndexFiletype];
  
  NSURL *url = [NSURL fileURLWithPath:pathWithType];
  if (!url) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return url;
}

- (NSURL *)indexDirectoryURL {
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  
  NSURL *url = [NSURL fileURLWithPath:workingDirectory isDirectory:YES];
  if (!url) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", workingDirectory);
  }
  return url;
}

- (NSURL *)templateFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateMarkerFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateMarkerFiletype];
  
  NSURL *url = [NSURL fileURLWithPath:pathWithType];
  if (!url) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return url;
}

- (NSURL *)jsonFileURL {
  
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *filepath = [workingDirectory stringByAppendingPathComponent:kTemplateJsonFilename];
  NSString *pathWithType = [filepath stringByAppendingPathExtension:kTemplateJsonFiletype];
  
  NSURL *url = [NSURL fileURLWithPath:pathWithType];
  if (!url) {
    NSLog(@"Error! NSURL:fileURLWithPath: [%@]", pathWithType);
  }
  return url;
}

// Copy the entire template folder from main bundle to the documents directory one time
-(void)copyBundleTemplateDirectory {
  FileManager *fileManager = [[FileManager alloc] init];
  [fileManager copyDirectory:self.templateDirectory overwrite:NO documentsDirectory:self.documentsDirectory];
}
  
- (void)loadImagesFromFiles {
  
  NSError *error;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *workingDirectory = [self.documentsDirectory stringByAppendingPathComponent:self.templateDirectory];
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImageDirectory];
  
  NSArray *files = [fileManager contentsOfDirectoryAtPath:imagesDirectory error:&error];
  
  for (NSString *file in files) {
    BOOL isDirectory;
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:file];
    [fileManager fileExistsAtPath:filepath isDirectory:&isDirectory];
    
    if (!isDirectory) {
      //NSLog(@"Image File at: %@", file);
      if ([file hasPrefix:kTemplateImagePrefix]) {
        
        // must read as NSData since write is as NSData
        NSData *imageData = [NSData dataWithContentsOfFile:filepath];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image) {
          // for now just add image to array
          // TODO - get image number from filename
          // TODO - perhaps switch to using a dictionary with number (or filename) as key
          [self.images addObject:image];
        }
      }
    }
  }
}

@end
