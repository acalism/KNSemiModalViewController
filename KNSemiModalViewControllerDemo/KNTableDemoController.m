//
//  KNTableDemoController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 4/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNTableDemoController.h"
#import "UIViewController+KNSemiModal.h"
#import "KNModalTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation KNTableDemoController

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
  NSLog(@"%s", __PRETTY_FUNCTION__);

  self = [super initWithCoder:coder];
  if (self) {
    self.title = @"Third";
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
    modalVC = [[KNModalTableViewController alloc] initWithStyle:UITableViewStylePlain];
  }
  return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Demo3Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  cell.textLabel.text = [NSString stringWithFormat:@"Demo row %zd", indexPath.row];
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  // You have to retain the ownership of ViewController that you are presenting
  
  KNSemiModalOption *option = KNSemiModalOption.new;
  option.pushParentBack = false;
  option.parentAlpha = 0.8;

  [self kns_presentSemiViewController:modalVC withOptions:option];
  
  // The following code won't work
//  KNModalTableViewController * vc = [[KNModalTableViewController alloc] initWithStyle:UITableViewStylePlain];
//  [self presentSemiViewController:vc];
}

@end

NS_ASSUME_NONNULL_END
