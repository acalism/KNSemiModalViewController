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
  NSLog(@"%s", __PRETTY_FUNCTION__);
  self = [super initWithCoder:coder];
  if (self) {
    self.title = NSLocalizedString(@"First", @"First");
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
  }
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

  KNSemiModalOption *option = KNSemiModalOption.new;
  option.backgroundView = bgimgv;
  option.parentAlpha = 0.5;
  option.parentScale = 1.0;
  option.pushParentBack = false;
  option.shadowOpacity = 0;
  option.transitionStyle = KNSemiModalTransitionStyleSlideUp;
  option.traverseParentHierarchy = true;
  option.animationDuration = 0.3;
  option.allowTapToDismiss = true;
  option.viewPosition = KNSemiModalViewPositionBottom;

  [self kns_presentSemiView:imagev withOptions:option];
}

@end

NS_ASSUME_NONNULL_END
