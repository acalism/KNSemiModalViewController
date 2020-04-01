//
//  KNSemiModalViewController.m
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


NS_ASSUME_NONNULL_BEGIN

NSNotificationName const kSemiModalDidShowNotification      = @"kSemiModalDidShowNotification";
NSNotificationName const kSemiModalDidHideNotification      = @"kSemiModalDidHideNotification";
NSNotificationName const kSemiModalWasResizedNotification   = @"kSemiModalWasResizedNotification";

#define kSemiModalDismissBlock             @"l27h7RU2dzVfPoQ"
#define kSemiModalPresentingViewController @"QKWuTQjUkWaO1Xr"
#define kSemiModalOverlayTag               10001
#define kSemiModalScreenshotTag            10002
#define kSemiModalModalViewTag             10003
#define kSemiModalDismissButtonTag         10004


@interface KNSemiModalOption ()
@property(nonatomic, strong, nullable) UIView *semiModalView;
@property(nonatomic, strong, nullable) UIViewController *semiModalViewController;
@end


@implementation KNSemiModalOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.traverseParentHierarchy = true;
        self.pushParentBack     = true;
        self.allowTapToDismiss  = true;
        self.transitionStyle    = KNSemiModalTransitionStyleSlideUp;
        self.viewPosition       = KNSemiModalViewPositionBottom;
        self.animationDuration  = 0.5;
        self.parentAlpha        = 0.5;
        self.parentScale        = 0.8;
        self.shadowOpacity      = 0.8;
        self.backgroundView     = nil;
        self.semiModalView           = nil;
        self.semiModalViewController = nil;
    }
    return self;
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation
{
    return @{
        @"TraverseParentHierarchy"  : @(self.traverseParentHierarchy),
        @"PushParentBack"           : @(self.pushParentBack),
        @"AnimationDuration"        : @(self.animationDuration),
        @"ParentAlpha"              : @(self.parentAlpha),
        @"ParentScale"              : @(self.parentScale),
        @"ShadowOpacity"            : @(self.shadowOpacity),
        @"TransitionStyle"          : @(self.transitionStyle),
        @"AllowTapToDismiss"        : @(self.allowTapToDismiss),
        @"ViewPosition"             : @(self.viewPosition),
        @"BackgroundView"           : (self.backgroundView ?: @"nil"),
        @"SemiModalView"            : (self.semiModalView ?: @"nil"),
        @"SemiModalViewController"  : (self.semiModalViewController ?: @""),
    };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KNSemiModalOption: %@", self.dictionaryRepresentation];
}

@end

NS_ASSUME_NONNULL_END




NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (KNSemiModalInternal)
- (UIView *)kns_parentTarget;
- (CAAnimationGroup *)kns_animationGroupForward:(BOOL)forward;
@property(nonatomic, strong, nullable, setter=kns_setModalOption:) KNSemiModalOption *kns_modalOption;
@end

@implementation UIViewController (KNSemiModalInternal)

// MARK: Associated Property

static char s_keyModalOption;
- (nullable KNSemiModalOption *)kns_modalOption {
    KNSemiModalOption *option = objc_getAssociatedObject(self, &s_keyModalOption);
    return option;
}
- (void)kns_setModalOption:(nullable KNSemiModalOption *)option {
    objc_setAssociatedObject(self, &s_keyModalOption, option, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// MARK: - Traverse View Controller


- (UIViewController*)kns_parentTargetViewController {
    UIViewController * target = self;
    BOOL traverseParentHierarchy = self.kns_modalOption.traverseParentHierarchy;
    if (traverseParentHierarchy) {
        // cover UINav & UITabbar as well
        while (target.parentViewController != nil) {
            target = target.parentViewController;
        }
    }
    return target;
}
- (UIView *)kns_parentTarget {
    return [self kns_parentTargetViewController].view;
}


// MARK: Push-back animation group

- (CAAnimationGroup*)kns_animationGroupForward:(BOOL)forward
{
    KNSemiModalOption *option = self.kns_modalOption;

    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0 / -900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // The rotation angle is minor as the view is nearer
        t1 = CATransform3DRotate(t1, 7.5 * M_PI / 180.0, 1, 0, 0);
    } else {
        t1 = CATransform3DRotate(t1, 15.0 * M_PI / 180.0, 1, 0, 0);
    }
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    CGFloat scale = option.parentScale;
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Minor shift to mantai perspective
        t2 = CATransform3DTranslate(t2, 0, [self kns_parentTarget].frame.size.height * -0.04, 0);
        t2 = CATransform3DScale(t2, scale, scale, 1);
    } else {
        t2 = CATransform3DTranslate(t2, 0, [self kns_parentTarget].frame.size.height * -0.08, 0);
        t2 = CATransform3DScale(t2, scale, scale, 1);
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    CFTimeInterval duration = option.animationDuration;
    animation.duration = duration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(forward ? t2 : CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

- (void)kns_interfaceOrientationDidChange:(NSNotification*)notification {
    UIView *overlay = [[self kns_parentTarget] viewWithTag:kSemiModalOverlayTag];
    [self kns_addOrUpdateParentScreenshotInView:overlay];
}

- (UIImageView *)kns_addOrUpdateParentScreenshotInView:(UIView*)screenshotContainer {
    UIView *target = [self kns_parentTarget];
    UIView *semiView = [target viewWithTag:kSemiModalModalViewTag];

    screenshotContainer.hidden = YES; // screenshot without the overlay!
    semiView.hidden = YES;
    UIGraphicsBeginImageContextWithOptions(target.bounds.size, YES, UIScreen.mainScreen.scale);
    if ([target respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [target drawViewHierarchyInRect:target.bounds afterScreenUpdates:YES];
    } else {
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    screenshotContainer.hidden = NO;
    semiView.hidden = NO;

    UIImageView *screenshot = (id) [screenshotContainer viewWithTag:kSemiModalScreenshotTag];
    if ([screenshot isKindOfClass:UIImageView.class]) {
        screenshot.image = image;
    } else {
        screenshot = [[UIImageView alloc] initWithImage:image];
        screenshot.tag = kSemiModalScreenshotTag;
        screenshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [screenshotContainer addSubview:screenshot];
    }
    return screenshot;
}

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (KNSemiModal)

- (void)kns_presentSemiViewController:(UIViewController *)vc
                          withOptions:(nullable KNSemiModalOption *)option
{
    if (option == nil) {
        option = KNSemiModalOption.new;
    }
    option.semiModalViewController = vc;
    self.kns_modalOption = option;

    KNTransitionCompletionBlock completion = option.completion;

    UIViewController *targetParentVC = [self kns_parentTargetViewController];

    // implement view controller containment for the semi-modal view controller
    [targetParentVC addChildViewController:vc];
    if ([vc respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
        [vc beginAppearanceTransition:YES animated:YES]; // iOS 6
    }
    option.completion = ^{
        [vc didMoveToParentViewController:targetParentVC];
        if ([vc respondsToSelector:@selector(endAppearanceTransition)]) {
            [vc endAppearanceTransition]; // iOS 6
        }
        if (nil != completion) {
            completion();
        }
    };
    [self kns_presentSemiView:vc.view withOptions:option];
}

- (void)kns_presentSemiView:(UIView*)view
                withOptions:(nullable KNSemiModalOption *)option
{
    if (nil == option) {
        option = KNSemiModalOption.new;
    }
    option.semiModalView = view;
    self.kns_modalOption = option;

    UIView * target = [self kns_parentTarget];

    if (nil == target.subviews || [target.subviews containsObject:view]) {
        return;
    }

    // Set associative object
    objc_setAssociatedObject(view, kSemiModalPresentingViewController, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Register for orientation changes, so we can update the presenting controller screenshot
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc addObserver:self
           selector:@selector(kns_interfaceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];

    // Get transition style
    KNSemiModalTransitionStyle transitionStyle = option.transitionStyle;

    KNSemiModalViewPosition position = option.viewPosition;

    // Calculate all frames
    CGSize semiViewSize = view.frame.size;
    CGSize containerSize = target.frame.size;
    CGRect semiViewFrame;
    CGFloat x, y, width;
    CGFloat yOffset = semiViewSize.height;
    x = (containerSize.width - view.frame.size.width) / 2.0;
    y = containerSize.height - semiViewSize.height;
    width = semiViewSize.width;
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    switch (position) {
    case KNSemiModalViewPositionBottom:
        break;
    case KNSemiModalViewPositionCenter:
        y /= 2.0;
        yOffset = (containerSize.height + semiViewSize.height) / 2.0;
        view.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        break;
    case KNSemiModalViewPositionTop:
        y = 0;
        yOffset = -(containerSize.height + semiViewSize.height) / 2.0;
        view.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
        break;
    default:
        [NSException raise:NSInvalidArgumentException
                    format:@"%s: invalid viewPosition: %zd", __PRETTY_FUNCTION__, position];
        break;
    }

    semiViewFrame = (CGRect){
        .origin = {.x = x, .y = y},
        .size = {.width = width, .height = semiViewSize.height}
    };

    CGRect overlayFrame = (CGRect){
        .origin = CGPointZero,
        .size = {
            .width = containerSize.width,
            .height = containerSize.height - semiViewSize.height,
        },
    };

    // Add semi overlay
    UIView *overlay;
    UIView *backgroundView = option.backgroundView;
    if (nil != backgroundView) {
        overlay = backgroundView;
    } else {
        overlay = UIView.new;
    }

    overlay.frame = target.bounds;
    overlay.backgroundColor = UIColor.blackColor;
    overlay.userInteractionEnabled = YES;
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlay.tag = kSemiModalOverlayTag;

    // Take screenshot and scale
    UIImageView *ss = [self kns_addOrUpdateParentScreenshotInView:overlay];
    [target addSubview:overlay];

    // Dismiss button (if allow)
    BOOL allowTapToDismiss = option.allowTapToDismiss;
    if (allowTapToDismiss) {
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(kns_dismissSemiModalView) forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = UIColor.clearColor;
        dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dismissButton.frame = overlayFrame;
        dismissButton.tag = kSemiModalDismissButtonTag;
        [overlay addSubview:dismissButton];
    }

    // Begin overlay animation
    if (option.pushParentBack) {
        [ss.layer addAnimation:[self kns_animationGroupForward:YES] forKey:@"pushedBackAnimation"];
    }
    NSTimeInterval duration = option.animationDuration;
    [UIView animateWithDuration:duration animations:^{
        ss.alpha = option.parentAlpha;
    }];

    // Present view animated
    switch (transitionStyle) {
    case KNSemiModalTransitionStyleSlideUp:
        view.frame = CGRectOffset(semiViewFrame, 0, yOffset);
        break;
    case KNSemiModalTransitionStyleFadeIn:
    case KNSemiModalTransitionStyleFadeInOut:
        view.frame = semiViewFrame;
        view.alpha = 0;
        break;
    default:
        view.frame = semiViewFrame;
        break;
    }

    view.tag = kSemiModalModalViewTag;
    [target addSubview:view];
    view.layer.shadowColor = UIColor.blackColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(0, -2);
    view.layer.shadowRadius = 5.0;
    view.layer.shadowOpacity = option.shadowOpacity;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = UIScreen.mainScreen.scale;

    KNTransitionCompletionBlock completion = option.completion;

    [UIView animateWithDuration:duration animations:^{
        switch (transitionStyle) {
        case KNSemiModalTransitionStyleSlideUp:
            view.frame = semiViewFrame;
            break;
        case KNSemiModalTransitionStyleFadeIn:
        case KNSemiModalTransitionStyleFadeInOut:
            view.alpha = 1.0;
            break;
        default:
            break;
        }
    } completion:^(BOOL finished) {
        if (!finished) { return; }
        NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
        [nc postNotificationName:kSemiModalDidShowNotification object:self];
        if (nil != completion) {
            completion();
        }
    }];
}

- (void)kns_updateBackground {
    UIView * target = [self kns_parentTarget];
    UIView * overlay = [target viewWithTag:kSemiModalOverlayTag];
    [self kns_addOrUpdateParentScreenshotInView:overlay];
}

- (void)kns_dismissSemiModalView {
    [self kns_dismissSemiModalViewWithCompletion:nil];
}

- (void)kns_dismissSemiModalViewWithCompletion:(nullable void (^)(void))completion
{
    // Look for presenting controller if available
    UIViewController * prstingTgt = self;
    UIViewController * presentingController = objc_getAssociatedObject(prstingTgt.view, kSemiModalPresentingViewController);
    while (presentingController == nil && prstingTgt.parentViewController != nil) {
        prstingTgt = prstingTgt.parentViewController;
        presentingController = objc_getAssociatedObject(prstingTgt.view, kSemiModalPresentingViewController);
    }
    if (nil != presentingController) {
        objc_setAssociatedObject(presentingController.view, kSemiModalPresentingViewController, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [presentingController kns_dismissSemiModalViewWithCompletion:completion];
        return;
    }

    KNSemiModalOption *option = self.kns_modalOption;

    // Correct target for dismissal
    UIView * target = [self kns_parentTarget];
    UIView * modal = [target viewWithTag:kSemiModalModalViewTag];
    UIView * overlay = [target viewWithTag:kSemiModalOverlayTag];
    NSUInteger transitionStyle = option.transitionStyle;
    NSTimeInterval duration = option.animationDuration;
    UIViewController *vc = option.semiModalViewController;
    KNTransitionCompletionBlock dismissBlock = option.dismissBlock;

    // Child controller containment
    [vc willMoveToParentViewController:nil];
    if ([vc respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
        [vc beginAppearanceTransition:NO animated:YES]; // iOS 6
    }

    [UIView animateWithDuration:duration animations:^{
        if (transitionStyle == KNSemiModalTransitionStyleSlideUp) {
            if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                // As the view is centered, we perform a vertical translation
                modal.frame = CGRectMake((target.bounds.size.width - modal.frame.size.width) / 2.0, target.bounds.size.height, modal.frame.size.width, modal.frame.size.height);
            } else {
                modal.frame = CGRectMake(0, target.bounds.size.height, modal.frame.size.width, modal.frame.size.height);
            }
        } else if (transitionStyle == KNSemiModalTransitionStyleFadeOut || transitionStyle == KNSemiModalTransitionStyleFadeInOut) {
            modal.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
        
        // Child controller containment
        [vc removeFromParentViewController];
        if ([vc respondsToSelector:@selector(endAppearanceTransition)]) {
            [vc endAppearanceTransition];
        }
        
        if (nil != dismissBlock) {
            dismissBlock();
        }

        option.dismissBlock = nil;
        option.semiModalViewController = nil;

        NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
        [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    }];
    
    // Begin overlay animation
    UIImageView * ss = (UIImageView*)overlay.subviews.firstObject;
    if (option.pushParentBack) {
        [ss.layer addAnimation:[self kns_animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    }
    [UIView animateWithDuration:duration animations:^{
        ss.alpha = 1;
    } completion:^(BOOL finished) {
        if(finished){
            NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
            [nc postNotificationName:kSemiModalDidHideNotification object:self];
            if (nil != completion) {
                completion();
            }
        }
    }];
}

- (void)kns_resizeSemiView:(CGSize)newSize
{
    KNSemiModalOption *option = self.kns_modalOption;
    UIView * target = [self kns_parentTarget];
    UIView * modal = [target viewWithTag:kSemiModalModalViewTag];
    CGRect mf = modal.frame;
    mf.size.width = newSize.width;
    mf.size.height = newSize.height;
    mf.origin.y = target.frame.size.height - mf.size.height;
    UIView * overlay = [target viewWithTag:kSemiModalOverlayTag];
    UIButton * button = (UIButton*)[overlay viewWithTag:kSemiModalDismissButtonTag];
    CGRect bf = button.frame;
    bf.size.height = overlay.frame.size.height - newSize.height;
    NSTimeInterval duration = option.animationDuration;
    [UIView animateWithDuration:duration animations:^{
        modal.frame = mf;
        button.frame = bf;
    } completion:^(BOOL finished) {
        if (finished) {
            NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
            [nc postNotificationName:kSemiModalWasResizedNotification object:self];
        }
    }];
}

@end

NS_ASSUME_NONNULL_END




// MARK: - UIView (FindUIViewController)

// Convenient category method to find actual ViewController that contains a view
// Adapted from: http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone

NS_ASSUME_NONNULL_BEGIN

@implementation UIView (FindUIViewController)

- (nullable UIViewController *)kns_containingViewController
{
    UIView * target = self.superview ? self.superview : self;
    return [target kns_traverseResponderChainForUIViewController];
}

- (nullable UIViewController *)kns_traverseResponderChainForUIViewController
{
    id nextResponder = [self nextResponder];
    BOOL isViewController = [nextResponder isKindOfClass: UIViewController.class];
    BOOL isTabBarController = [nextResponder isKindOfClass: UITabBarController.class];
    if (isViewController && !isTabBarController) {
        return nextResponder;
    } else if (isTabBarController){
        UITabBarController *tabBarController = nextResponder;
        return [tabBarController selectedViewController];
    } else if ([nextResponder isKindOfClass: UIView.class]) {
        return [nextResponder kns_traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
@end

NS_ASSUME_NONNULL_END
