//
//  RepoPickerDelegate.h
//  Instasite
//
//  Created by mike davis on 11/12/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RepoPickerViewController;

@protocol RepoPickerDelegate <NSObject>

- (void)repoPicker:(RepoPickerViewController *)picker didFinishPickingWithName:(NSString *)name;
- (void)repoPickerDidCancel:(RepoPickerViewController *)picker;

@end

