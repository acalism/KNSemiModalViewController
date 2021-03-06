//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "KNThirdViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>


NS_ASSUME_NONNULL_BEGIN


@interface KNThirdViewController ()

@end

@implementation KNThirdViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.dismissButton.layer.cornerRadius  = 10.0f;
  self.dismissButton.layer.masksToBounds = YES;
  self.resizeButton.layer.cornerRadius   = 10.0f;
  self.resizeButton.layer.masksToBounds  = YES;
}


- (IBAction)dismissButtonDidTouch:(id)sender {

  // Here's how to call dismiss button on the parent ViewController
  // be careful with view hierarchy
  UIViewController * parent = [self.view kns_containingViewController];
  if ([parent respondsToSelector:@selector(kns_dismissSemiModalView)]) {
    [parent kns_dismissSemiModalView];
  }

}

- (IBAction)resizeSemiModalView:(id)sender
{
  UIViewController * parent = [self.view kns_containingViewController];
  if ([parent respondsToSelector:@selector(kns_resizeSemiView:)]) {
    [parent kns_resizeSemiView:CGSizeMake(320, arc4random() % 280 + 180)];
  }
}

@end

NS_ASSUME_NONNULL_END
