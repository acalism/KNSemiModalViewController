//
//  KNTableDemoController.h
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 4/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KNModalTableViewController;

@interface KNTableDemoController : UITableViewController {
  KNModalTableViewController * modalVC;
}

@end

NS_ASSUME_NONNULL_END
