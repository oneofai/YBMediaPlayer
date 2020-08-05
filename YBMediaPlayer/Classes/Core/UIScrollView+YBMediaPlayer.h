//
//  UIScrollView+YBMediaPlayer.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * The scroll direction of scrollView.
 */
typedef NS_ENUM(NSUInteger, YBPlayerScrollDirection) {
    YBPlayerScrollDirectionNone,
    YBPlayerScrollDirectionUp,         // Scroll up
    YBPlayerScrollDirectionDown,       // Scroll Down
    YBPlayerScrollDirectionLeft,       // Scroll left
    YBPlayerScrollDirectionRight       // Scroll right
};

/*
 * The scrollView direction.
 */
typedef NS_ENUM(NSInteger, YBPlayerScrollViewDirection) {
    YBPlayerScrollViewDirectionVertical,
    YBPlayerScrollViewDirectionHorizontal
};

/*
 * The player container type
 */
typedef NS_ENUM(NSInteger, YBPlayerContainerType) {
    YBPlayerContainerTypeCell,
    YBPlayerContainerTypeView
};

@interface UIScrollView (YBMediaPlayer)

/// When the YBPlayerScrollViewDirection is YBPlayerScrollViewDirectionVertical,the property has value.
@property (nonatomic, readonly) CGFloat yb_lastOffsetY;

/// When the YBPlayerScrollViewDirection is YBPlayerScrollViewDirectionHorizontal,the property has value.
@property (nonatomic, readonly) CGFloat yb_lastOffsetX;

/// The indexPath is playing.
@property (nonatomic, nullable) NSIndexPath *yb_playingIndexPath;

/// The indexPath that should play, the one that lights up.
@property (nonatomic, nullable) NSIndexPath *yb_shouldPlayIndexPath;

/// WWANA networks play automatically,default NO.
@property (nonatomic, getter=yb_isWWANAutoPlay) BOOL yb_WWANAutoPlay;

/// The player should auto player,default is YES.
@property (nonatomic) BOOL yb_shouldAutoPlay;

/// The view tag that the player display in scrollView.
@property (nonatomic) NSInteger yb_containerViewTag;

/// The scrollView scroll direction, default is YBPlayerScrollViewDirectionVertical.
@property (nonatomic) YBPlayerScrollViewDirection yb_scrollViewDirection;

/// The scroll direction of scrollView while scrolling.
/// When the YBPlayerScrollViewDirection is YBPlayerScrollViewDirectionVertical，this value can only be YBPlayerScrollDirectionUp or YBPlayerScrollDirectionDown.
/// When the YBPlayerScrollViewDirection is YBPlayerScrollViewDirectionVertical，this value can only be YBPlayerScrollDirectionLeft or YBPlayerScrollDirectionRight.
@property (nonatomic, readonly) YBPlayerScrollDirection yb_scrollDirection;

/// The video contrainerView type.
@property (nonatomic, assign) YBPlayerContainerType yb_containerType;

/// The video contrainerView in normal model.
@property (nonatomic, strong) UIView *yb_containerView;

/// The currently playing cell stop playing when the cell has out off the screen，defalut is YES.
@property (nonatomic, assign) BOOL yb_stopWhileNotVisible;

/// Has stopped playing
@property (nonatomic, assign) BOOL yb_stopPlay;

/// The block invoked When the player did stop scroll.
@property (nonatomic, copy, nullable) void(^yb_scrollViewDidStopScrollCallback)(NSIndexPath *indexPath);

/// The block invoked When the player should play.
@property (nonatomic, copy, nullable) void(^yb_shouldPlayIndexPathCallback)(NSIndexPath *indexPath);

/// Filter the cell that should be played when the scroll is stopped (to play when the scroll is stopped).
- (void)yb_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Filter the cell that should be played while scrolling (you can use this to filter the highlighted cell).
- (void)yb_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Get the cell according to indexPath.
- (UIView *)yb_getCellForIndexPath:(NSIndexPath *)indexPath;

/// Scroll to indexPath with animations.
- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.4 version.
/// Scroll to indexPath with animations.
- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.8 version.
/// Scroll to indexPath with animations duration.
- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler;

///------------------------------------
/// The following method must be implemented in UIScrollViewDelegate.
///------------------------------------

- (void)yb_scrollViewDidEndDecelerating;

- (void)yb_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate;

- (void)yb_scrollViewDidScrollToTop;

- (void)yb_scrollViewDidScroll;

- (void)yb_scrollViewWillBeginDragging;

///------------------------------------
/// end
///------------------------------------


@end

@interface UIScrollView (YBPlayerCannotCalled)

/// The block invoked When the player appearing.
@property (nonatomic, copy, nullable) void(^yb_playerAppearingInScrollView)(NSIndexPath *indexPath, CGFloat playerApperaPercent);

/// The block invoked When the player disappearing.
@property (nonatomic, copy, nullable) void(^yb_playerDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);

/// The block invoked When the player will appeared.
@property (nonatomic, copy, nullable) void(^yb_playerWillAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did appeared.
@property (nonatomic, copy, nullable) void(^yb_playerDidAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player will disappear.
@property (nonatomic, copy, nullable) void(^yb_playerWillDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did disappeared.
@property (nonatomic, copy, nullable) void(^yb_playerDidDisappearInScrollView)(NSIndexPath *indexPath);

/// The current player scroll slides off the screen percent.
/// the property used when the `stopWhileNotVisible` is YES, stop the current playing player.
/// the property used when the `stopWhileNotVisible` is NO, the current playing player add to small container view.
/// 0.0~1.0, defalut is 0.5.
/// 0.0 is the player will disappear.
/// 1.0 is the player did disappear.
@property (nonatomic) CGFloat yb_playerDisapperaPercent;

/// The current player scroll to the screen percent to play the video.
/// 0.0~1.0, defalut is 0.0.
/// 0.0 is the player will appear.
/// 1.0 is the player did appear.
@property (nonatomic) CGFloat yb_playerApperaPercent;

/// The current player controller is disappear, not dealloc
@property (nonatomic) BOOL yb_viewControllerDisappear;

@end

NS_ASSUME_NONNULL_END
