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

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self copyBundleTemplateDirectory];
  
  NSURL *templateURL = [self templateHtmlURL];
  self.templateCopy = [[HtmlTemplate alloc] initWithURL:templateURL];
  
  self.images = [[NSMutableArray alloc] init];
  [self loadImagesFromFiles];
}


#pragma mark - Helper Methods

- (NSURL *)templateHtmlURL {
  return [HtmlTemplate fileURL:kTemplateMarkerFilename type:kTemplateMarkerFiletype templateDirectory:self.templateDirectory documentsDirectory:self.documentsDirectory];
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
  NSString *imagesDirectory = [workingDirectory stringByAppendingPathComponent:kTemplateImagesDirectory];
  
  NSArray *files = [fileManager contentsOfDirectoryAtPath:imagesDirectory error:&error];
  
  for (NSString *file in files) {
    BOOL isDirectory;
    NSString *filepath = [imagesDirectory stringByAppendingPathComponent:file];
    [fileManager fileExistsAtPath:filepath isDirectory:&isDirectory];
    
    if (!isDirectory) {
      //NSLog(@"Image File at: %@", file);
      if ([file hasPrefix:kTemplateImagePrefix]) {
        UIImage *image = [UIImage imageWithContentsOfFile:filepath];
        if (image) {
          // for now just add image to array
          // TODO - get image number from filename
          // TODO - switch to using a dictionary with number (or filename) as key
          [self.images addObject:image];
        }
      }
    }
  }
}

@end
