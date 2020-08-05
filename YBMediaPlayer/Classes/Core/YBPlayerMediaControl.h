//
//  YBPlayerMediaControl.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBPlayerMediaPlayback.h"
#import "YBPlayerOrientationObserver.h"
#import "YBPlayerGestureControl.h"
#import "YBPlayerReachabilityManager.h"
@class YBPlayerController;

NS_ASSUME_NONNULL_BEGIN

@protocol YBPlayerMediaControl <NSObject>

@required
/// Current playerController
@property (nonatomic, weak) YBPlayerController *player;

@optional

#pragma mark - Playback state

/// When the player prepare to play the video.
- (void)videoPlayer:(YBPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL;

/// When th player playback state changed.
- (void)videoPlayer:(YBPlayerController *)videoPlayer playStateChanged:(YBPlayerPlaybackState)state;

/// When th player loading state changed.
- (void)videoPlayer:(YBPlayerController *)videoPlayer loadStateChanged:(YBPlayerLoadState)state;

#pragma mark - progress

/**
 When the playback changed.
 
 @param videoPlayer the player.
 @param currentTime the current play time.
 @param totalTime the video total time.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer
        currentTime:(NSTimeInterval)currentTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When buffer progress changed.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer
         bufferTime:(NSTimeInterval)bufferTime;

/**
 When you are dragging to change the video progress.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer
       draggingTime:(NSTimeInterval)seekTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When play end.
 */
- (void)videoPlayerPlayEnd:(YBPlayerController *)videoPlayer;

/**
 When play failed.
 */
- (void)videoPlayerPlayFailed:(YBPlayerController *)videoPlayer error:(id)error;

#pragma mark - lock screen

/**
 When set `videoPlayer.lockedScreen`.
 */
- (void)lockedVideoPlayer:(YBPlayerController *)videoPlayer lockedScreen:(BOOL)locked;

#pragma mark - Screen rotation

/**
 When the fullScreen maode will changed.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer orientationWillChange:(YBPlayerOrientationObserver *)observer;

/**
 When the fullScreen maode did changed.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer orientationDidChanged:(YBPlayerOrientationObserver *)observer;

#pragma mark - The network changed

/**
 When the network changed
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer reachabilityChanged:(YBPlayerReachabilityStatus)status;

#pragma mark - The video size changed

/**
 When the video size changed
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size;

#pragma mark - 设置了 AssetURLs

/// 播放器已经设置了资源 URLs
/// @param videoPlayer 播放器
/// @param didPlayFirstAsset 播放第一节
/// @param didPlayLastAsset 播放最后一节
/// @param assetURLs 资源地址集合
- (void)videoPlayer:(YBPlayerController *)videoPlayer didPlayFirstAsset:(BOOL)didPlayFirstAsset didPlayLastAsset:(BOOL)didPlayLastAsset assetURLs:(NSArray <NSURL *> *)assetURLs;

#pragma mark - Gesture

/**
 When the gesture condition
 */
- (BOOL)gestureTriggerCondition:(YBPlayerGestureControl *)gestureControl
                    gestureType:(YBPlayerGestureType)gestureType
              gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                          touch:(UITouch *)touch;

/**
 When the gesture single tapped
 */
- (void)gestureSingleTapped:(YBPlayerGestureControl *)gestureControl;

/**
 When the gesture double tapped
 */
- (void)gestureDoubleTapped:(YBPlayerGestureControl *)gestureControl;

/**
 When the gesture begin panGesture
 */
- (void)gestureBeganPan:(YBPlayerGestureControl *)gestureControl
           panDirection:(YBPanDirection)direction
            panLocation:(YBPanLocation)location;

/**
 When the gesture paning
 */
- (void)gestureChangedPan:(YBPlayerGestureControl *)gestureControl
             panDirection:(YBPanDirection)direction
              panLocation:(YBPanLocation)location
             withVelocity:(CGPoint)velocity;

/**
 When the end panGesture
 */
- (void)gestureEndedPan:(YBPlayerGestureControl *)gestureControl
           panDirection:(YBPanDirection)direction
            panLocation:(YBPanLocation)location;

/**
 When the pinchGesture changed
 */
- (void)gesturePinched:(YBPlayerGestureControl *)gestureControl
                 scale:(float)scale;

#pragma mark - scrollview

/**
 When the player will appear in scrollView.
 */
- (void)playerWillAppearInScrollView:(YBPlayerController *)videoPlayer;

/**
 When the player did appear in scrollView.
 */
- (void)playerDidAppearInScrollView:(YBPlayerController *)videoPlayer;

/**
 When the player will disappear in scrollView.
 */
- (void)playerWillDisappearInScrollView:(YBPlayerController *)videoPlayer;

/**
 When the player did disappear in scrollView.
 */
- (void)playerDidDisappearInScrollView:(YBPlayerController *)videoPlayer;

/**
 When the player appearing in scrollView.
 */
- (void)playerAppearingInScrollView:(YBPlayerController *)videoPlayer playerApperaPercent:(CGFloat)playerApperaPercent;

/**
 When the player disappearing in scrollView.
 */
- (void)playerDisappearingInScrollView:(YBPlayerController *)videoPlayer playerDisapperaPercent:(CGFloat)playerDisapperaPercent;

/**
 When the small float view show.
 */
- (void)videoPlayer:(YBPlayerController *)videoPlayer floatViewShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END

