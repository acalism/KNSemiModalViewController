//
//  KNModalTableViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 4/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNModalTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KNModalTableViewController ()

@end

@implementation KNModalTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
  NSLog(@"%s", __PRETTY_FUNCTION__);

  self = [super initWithStyle:style];
  if (self) {
    self.view.frame = CGRectMake(0, 0, 320, 200);
  }
  return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ModalCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  cell.textLabel.text = [NSString stringWithFormat:@"Crazy shit %zd", indexPath.row];
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

NS_ASSUME_NONNULL_END
