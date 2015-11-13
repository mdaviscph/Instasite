//
//  TemplatePickerViewController.m
//  Instasite
//
//  Created by Cathy Oun on 9/23/15.
//  Copyright © 2015 Instasite. All rights reserved.
//

#import "TemplatePickerViewController.h"
#import "TemplateCell.h"
#import "TemplateView.h"

static NSString *kCellId = @"MainCell";

@interface TemplatePickerViewController () <UITableViewDataSource, TemplateCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *templateDirectories;
@property (nonatomic) NSUInteger templatesPerRow;
@property (strong, nonatomic) NSArray *imageNames;
@property (strong, nonatomic) NSArray *titles;

@end

@implementation TemplatePickerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // TODO - read this list from the bundle directory
  self.templateDirectories = @[@"startbootstrap-1-col-portfolio-1.0.3",
                               @"startbootstrap-one-page-wonder-1.0.3",
                               @"startbootstrap-landing-page-1.0.4",
                               @"startbootstrap-agency-1.0-2.4",
                               @"startbootstrap-freelancer-1.0.3",
                               @"startbootstrap-creative-1.0.1",
                               @"startbootstrap-clean-blog-1.0.3"];
  self.imageNames = @[@"1-col-portfolio",@"one-page-wonder",@"landing-page",@"agency",@"freelancer",@"creative",@"clean-blog"];
  self.titles = @[@"One Column Portfolio",@"One Page Wonder",@"Landing Page",@"Agency",@"Freelancer",@"Creative",@"Clean Blog"];
  
  self.tableView.dataSource = self;
  [self.tableView registerClass:[TemplateCell class] forCellReuseIdentifier:kCellId];
  
  self.tableView.estimatedRowHeight = 44;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  
  self.navigationItem.title = @"Templates";
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped)];
  
  self.templatesPerRow = 2;
}

//- (void)viewDidLayoutSubviews {
//  [super viewDidLayoutSubviews];
//  
//  self.templatesPerRow = self.view.bounds.size.width / 100;
//}

#pragma mark - Selector Methods

- (void)cancelTapped {
  if ([self.delegate respondsToSelector:@selector(templatePickerDidCancel:)]) {
    [self.delegate templatePickerDidCancel:self];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger count = (self.templateDirectories.count + (self.templatesPerRow - 1)) / self.templatesPerRow;    // round up
  return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  TemplateCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
  
  NSMutableArray<TemplateView *> *templates = [[NSMutableArray alloc] init];
  NSUInteger start = start = indexPath.row * self.templatesPerRow;
  NSUInteger end = MIN(self.templateDirectories.count, (indexPath.row + 1) * self.templatesPerRow);
  for (NSUInteger index = start; index < end; index++) {
    [templates addObject:[[TemplateView alloc] initWithName:self.templateDirectories[index] title:self.titles[index] image:[UIImage imageNamed:self.imageNames[index]]]];
  }
  
  cell.delegate = self;
  cell.templates = [[NSArray alloc] initWithArray:templates];
  return cell;
}

#pragma mark - TemplateCellDelegate

- (void)templateCell:(TemplateCell *)templateCell didSelectItemWithName:(NSString *)name {
  
  if ([self.delegate respondsToSelector:@selector(templatePicker:didFinishPickingWithName:)]) {
    [self.delegate templatePicker:self didFinishPickingWithName:name];
  }
}

@end
