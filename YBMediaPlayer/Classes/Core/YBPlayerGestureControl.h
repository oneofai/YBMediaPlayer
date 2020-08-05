//
//  YBPlayerGestureControl.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YBPlayerGestureType) {
    YBPlayerGestureTypeUnknown,
    YBPlayerGestureTypeSingleTap,
    YBPlayerGestureTypeDoubleTap,
    YBPlayerGestureTypePan,
    YBPlayerGestureTypePinch,
    YBPlayerGestureTypeLongPress
};

typedef NS_ENUM(NSUInteger, YBPanDirection) {
    YBPanDirectionUnknown,
    YBPanDirectionV,
    YBPanDirectionH,
};

typedef NS_ENUM(NSUInteger, YBPanLocation) {
    YBPanLocationUnknown,
    YBPanLocationLeft,
    YBPanLocationRight,
};

typedef NS_ENUM(NSUInteger, YBPanMovingDirection) {
    YBPanMovingDirectionUnkown,
    YBPanMovingDirectionTop,
    YBPanMovingDirectionLeft,
    YBPanMovingDirectionBottom,
    YBPanMovingDirectionRight,
};

/// This enumeration lists some of the gesture types that the player has by default.
typedef NS_OPTIONS(NSUInteger, YBPlayerDisableGestureTypes) {
    YBPlayerDisableGestureTypesNone         = 0,
    YBPlayerDisableGestureTypesSingleTap    = 1 << 0,
    YBPlayerDisableGestureTypesDoubleTap    = 1 << 1,
    YBPlayerDisableGestureTypesPan          = 1 << 2,
    YBPlayerDisableGestureTypesPinch        = 1 << 3,
    YBPlayerDisableGestureTypesLongPress    = 1 << 4,
    YBPlayerDisableGestureTypesAll          = (YBPlayerDisableGestureTypesSingleTap | YBPlayerDisableGestureTypesDoubleTap | YBPlayerDisableGestureTypesPan | YBPlayerDisableGestureTypesPinch | YBPlayerDisableGestureTypesLongPress)
};

/// This enumeration lists some of the pan gesture moving direction that the player not support.
typedef NS_OPTIONS(NSUInteger, YBPlayerDisablePanMovingDirection) {
    YBPlayerDisablePanMovingDirectionNone         = 0,       /// Not disable pan moving direction.
    YBPlayerDisablePanMovingDirectionVertical     = 1 << 0,  /// Disable pan moving vertical direction.
    YBPlayerDisablePanMovingDirectionHorizontal   = 1 << 1,  /// Disable pan moving horizontal direction.
    YBPlayerDisablePanMovingDirectionAll          = (YBPlayerDisablePanMovingDirectionVertical | YBPlayerDisablePanMovingDirectionHorizontal)  /// Disable pan moving all direction.
};

@interface YBPlayerGestureControl : NSObject

/// Gesture condition callback.
@property (nonatomic, copy, nullable) BOOL(^triggerCondition)(YBPlayerGestureControl *control, YBPlayerGestureType type, UIGestureRecognizer *gesture, UITouch *touch);

/// Single tap gesture callback.
@property (nonatomic, copy, nullable) void(^singleTapped)(YBPlayerGestureControl *control);

/// Double tap gesture callback.
@property (nonatomic, copy, nullable) void(^doubleTapped)(YBPlayerGestureControl *control);

/// Begin pan gesture callback.
@property (nonatomic, copy, nullable) void(^beganPan)(YBPlayerGestureControl *control, YBPanDirection direction, YBPanLocation location);

/// Pan gesture changing callback.
@property (nonatomic, copy, nullable) void(^changedPan)(YBPlayerGestureControl *control, YBPanDirection direction, YBPanLocation location, CGPoint velocity);

/// End the Pan gesture callback.
@property (nonatomic, copy, nullable) void(^endedPan)(YBPlayerGestureControl *control, YBPanDirection direction, YBPanLocation location);

/// Pinch gesture callback.
@property (nonatomic, copy, nullable) void(^pinched)(YBPlayerGestureControl *control, float scale);

/// LongPress gesture callback
@property (nonatomic, copy, nullable) void(^longPressed)(YBPlayerGestureControl *control);

/// The single tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *singleTap;

/// The double tap gesture.
@property (nonatomic, strong, readonly) UITapGestureRecognizer *doubleTap;

/// The pan tap gesture.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGR;

/// The pinch tap gesture.
@property (nonatomic, strong, readonly) UIPinchGestureRecognizer *pinchGR;

/// The pan gesture direction.
@property (nonatomic, readonly) YBPanDirection panDirection;

/// The pan location.
@property (nonatomic, readonly) YBPanLocation panLocation;

/// The moving drection.
@property (nonatomic, readonly) YBPanMovingDirection panMovingDirection;

/// The gesture types that the player not support.
@property (nonatomic) YBPlayerDisableGestureTypes disableTypes;

/// The pan gesture moving direction that the player not support.
@property (nonatomic) YBPlayerDisablePanMovingDirection disablePanMovingDirection;

/**
 Add  all gestures(singleTap、doubleTap、panGR、pinchGR) to the view.
 */
- (void)addGestureToView:(UIView *)view;

/**
 Remove all gestures(singleTap、doubleTap、panGR、pinchGR) form the view.
 */
- (void)removeGestureToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
