//
//  KNFirstViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNFirstViewController.h"
#import "UIViewController+KNSemiModal.h"

NS_ASSUME_NONNULL_BEGIN

@interface KNFirstViewController ()

@end

@implementation KNFirstViewController

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    self.title = NSLocalizedString(@"First", @"First");
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
  }
  NSLog(@"%s", __PRETTY_FUNCTION__);
  return self;
}

- (BOOL)shouldAutorotate {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  NSLog(@"%s", __PRETTY_FUNCTION__);
  if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  }
  return UIInterfaceOrientationMaskAll;
}

- (IBAction)buttonDidTouch:(id)sender {
  // You can present a simple UIImageView or any other UIView like this,
  // without needing to take care of dismiss action
  UIImageView * imagev = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"temp.jpg"]];
  UIImageView * bgimgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_01"]];
  [self presentSemiView:imagev withOptions:@{ KNSemiModalOptionKeys.backgroundView:bgimgv }];
}

@end

NS_ASSUME_NONNULL_END
