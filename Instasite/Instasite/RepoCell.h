//
//  RepoCell.h
//  Instasite
//
//  Created by mike davis on 10/5/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RepoJsonResponse;

@interface RepoCell : UITableViewCell

@property (strong, nonatomic) RepoJsonResponse *repo;

@end
