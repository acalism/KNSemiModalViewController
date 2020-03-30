//
//  KNAboutViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 3/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNAboutViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface KNAboutViewController ()

@end

@implementation KNAboutViewController

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
  NSLog(@"%s", __PRETTY_FUNCTION__);

  self = [super initWithCoder:coder];
  if (self) {
    self.title = @"About";
    self.tabBarItem.image = [UIImage imageNamed:@"second"];
  }
  return self;
}


-(IBAction)blogButtonDidTouch:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://kentnguyen.com/"]];
}

-(IBAction)twitterButtonDidTouch:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/ntluan"]];
}


@end

NS_ASSUME_NONNULL_END
