//
//  PublishViewController.h
//  Instasite
//
//  Created by Joao Paulo Galvao Alves on 9/22/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishViewController : UIViewController

@property(strong, nonatomic) NSString *indexHtmlFilePath;
@property(strong, nonatomic) NSString *JSONfilePath;
@property(strong, nonatomic) NSArray *supportingFilePaths;
@property(strong, nonatomic) NSArray *imageFilePaths;


@end
