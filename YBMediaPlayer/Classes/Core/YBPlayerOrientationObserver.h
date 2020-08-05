//
//  YBPlayerOrientationObserver.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Full screen mode
typedef NS_ENUM(NSUInteger, YBFullScreenMode) {
    YBFullScreenModeAutomatic,  // Determine full screen mode automatically
    YBFullScreenModeLandscape,  // Landscape full screen mode
    YBFullScreenModePortrait    // Portrait full screen Model
};

/// Full screen mode on the view
typedef NS_ENUM(NSUInteger, YBRotateType) {
    YBRotateTypeNormal,         // Normal
    YBRotateTypeCell,           // Cell
    YBRotateTypeCellOther       // Cell mode add to other view
};

/**
 Rotation of support direction
 */
typedef NS_OPTIONS(NSUInteger, YBInterfaceOrientationMask) {
    YBInterfaceOrientationMaskPortrait = (1 << 0),
    YBInterfaceOrientationMaskLandscapeLeft = (1 << 1),
    YBInterfaceOrientationMaskLandscapeRight = (1 << 2),
    YBInterfaceOrientationMaskPortraitUpsideDown = (1 << 3),
    YBInterfaceOrientationMaskLandscape = (YBInterfaceOrientationMaskLandscapeLeft | YBInterfaceOrientationMaskLandscapeRight),
    YBInterfaceOrientationMaskAll = (YBInterfaceOrientationMaskPortrait | YBInterfaceOrientationMaskLandscapeLeft | YBInterfaceOrientationMaskLandscapeRight | YBInterfaceOrientationMaskPortraitUpsideDown),
    YBInterfaceOrientationMaskAllButUpsideDown = (YBInterfaceOrientationMaskPortrait | YBInterfaceOrientationMaskLandscapeLeft | YBInterfaceOrientationMaskLandscapeRight),
};

@interface YBPlayerOrientationObserver : NSObject

- (void)updateRotateView:(UIView *)rotateView
           containerView:(UIView *)containerView;

/// list play
- (void)cellModelRotateView:(UIView *)rotateView
           rotateViewAtCell:(UIView *)cell
              playerViewTag:(NSInteger)playerViewTag;

/// cell other view rotation
- (void)cellOtherModelRotateView:(UIView *)rotateView
                   containerView:(UIView *)containerView;

/// Container view of a full screen state player.
@property (nonatomic, strong) UIView *fullScreenContainerView;

/// Container view of a small screen state player.
@property (nonatomic, weak) UIView *containerView;

/// Use device orientation, default NO.
@property (nonatomic, assign) BOOL forceDeviceOrientation;

/// If the full screen.
@property (nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;

/// Lock screen orientation
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(YBPlayerOrientationObserver *observer, BOOL isFullScreen);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(YBPlayerOrientationObserver *observer, BOOL isFullScreen);

/// Full screen mode, the default landscape into full screen
@property (nonatomic) YBFullScreenMode fullScreenMode;

/// rotate duration, default is 0.30
@property (nonatomic) float duration;

/// The statusbar hidden.
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

/// The current orientation of the player.
/// Default is UIInterfaceOrientationPortrait.
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

/// Whether allow the video orientation rotate.
/// default is YES.
@property (nonatomic) BOOL allowOrentitaionRotation;

/// The support Interface Orientation,default is YBInterfaceOrientationMaskAllButUpsideDown
@property (nonatomic, assign) YBInterfaceOrientationMask supportInterfaceOrientation;

/// Add the device orientation observer.
- (void)addDeviceOrientationObserver;

/// Remove the device orientation observer.
- (void)removeDeviceOrientationObserver;

/// Enter the fullScreen while the YBFullScreenMode is YBFullScreenModeLandscape.
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// Enter the fullScreen while the YBFullScreenMode is YBFullScreenModePortrait.
- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

- (void)exitFullScreenWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END


