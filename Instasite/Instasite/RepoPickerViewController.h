//
//  RepoPickerViewController.h
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepoPickerDelegate.h"

@interface RepoPickerViewController : UITableViewController

@property (weak, nonatomic) id<RepoPickerDelegate> delegate;
@property (strong, nonatomic) NSString *accessToken;

@end
