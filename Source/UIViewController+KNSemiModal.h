//
//  KNSemiModalViewController.h
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, KNSemiModalTransitionStyle) {
    KNSemiModalTransitionStyleSlideUp,
    KNSemiModalTransitionStyleFadeInOut,
    KNSemiModalTransitionStyleFadeIn,
    KNSemiModalTransitionStyleFadeOut,
};

typedef NS_ENUM(NSInteger, KNSemiModalViewPosition) {
    KNSemiModalViewPositionBottom,
    KNSemiModalViewPositionCenter,
    KNSemiModalViewPositionTop,
};


NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const kSemiModalDidShowNotification;
extern NSNotificationName const kSemiModalDidHideNotification;
extern NSNotificationName const kSemiModalWasResizedNotification;


typedef void (^KNTransitionCompletionBlock)(void);

@interface KNSemiModalOption: NSObject
@property(nonatomic, strong, nullable) UIView *backgroundView;  // custom background
@property(nonatomic) BOOL traverseParentHierarchy;              // default is YES
@property(nonatomic) BOOL pushParentBack;       // push parent back when presenting, default is YES.
@property(nonatomic) BOOL allowTapToDismiss;    // allow to tap background to dismiss, default is YES
@property(nonatomic) KNSemiModalTransitionStyle transitionStyle;
@property(nonatomic) KNSemiModalViewPosition viewPosition;
@property(nonatomic) CGFloat animationDuration; // in seconds. default is 0.5.
@property(nonatomic) CGFloat parentAlpha;       // lower is darker. default is 0.5.
@property(nonatomic) CGFloat parentScale;       // 1.0 is original. default is 0.8
@property(nonatomic) CGFloat shadowOpacity;     // lower is dimmer. default is 0.8
/// Is called after `-[vc viewDidAppear:]`.
@property(nonatomic, copy, nullable) KNTransitionCompletionBlock completion;
/// Is called when the user dismisses the semi-modal view by tapping the dimmed receiver view.
@property(nonatomic, copy, nullable) KNTransitionCompletionBlock dismissBlock;
@end


@interface UIViewController (KNSemiModal)

@property(nonatomic, strong, readonly, nullable) KNSemiModalOption *kns_modalOption;

/**
 Displays a view controller over the receiver, which is "dimmed".
 @param vc              The view controller to display semi-modally; its view's frame.size is used.
 @param option         See KNSemiModalOptionKeys constants.
 vc.view.frame.size is used
 */
- (void)kns_presentSemiViewController:(UIViewController *)vc
                          withOptions:(nullable KNSemiModalOption *)option;

// view.frame.size is used
- (void)kns_presentSemiView:(UIView *)view withOptions:(nullable KNSemiModalOption *)option;

// Update (refresh) backgroundView
- (void)kns_updateBackground;
// Dismiss & resize
- (void)kns_resizeSemiView:(CGSize)newSize;
- (void)kns_dismissSemiModalView;
- (void)kns_dismissSemiModalViewWithCompletion:(nullable KNTransitionCompletionBlock)completion;

@end



//==================================================================================================

//
// Convenient category method to find actual ViewController that contains a view
//
@interface UIView (FindUIViewController)
- (nullable UIViewController *)kns_containingViewController;
- (nullable UIViewController *)kns_traverseResponderChainForUIViewController;
@end


NS_ASSUME_NONNULL_END
