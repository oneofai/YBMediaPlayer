//
//  YBNetworkSpeedMonitor.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBPlayerPortraitControlView.h"
#import "YBPlayerLandscapeControlView.h"
#import "YBPlayerSpeedLoadingView.h"
#import "YBPlayerFloatingControlView.h"
#if __has_include(<YBMediaPlayer/YBPlayerMediaControl.h>)
#import <YBMediaPlayer/YBPlayerMediaControl.h>
#else
#import "YBPlayerMediaControl.h"
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YBPlayerControlViewScene) {
    // 书籍视频
    YBPlayerControlViewSceneBookVideo = 0x01,
    // 益伴小讲
    YBPlayerControlViewSceneSmalltalk,
    // 商学院
    YBPlayerControlViewSceneBusinessSchool,
    // 其他
    YBPlayerControlViewSceneOthers
};


@interface YBPlayerControlView : UIView <YBPlayerMediaControl>

/// 竖屏控制层的View
@property (nonatomic, strong, readonly) YBPlayerPortraitControlView *portraitControlView;

/// 横屏控制层的View
@property (nonatomic, strong, readonly) YBPlayerLandscapeControlView *landscapeControlView;

/// 加载loading
@property (nonatomic, strong, readonly) YBPlayerSpeedLoadingView *activity;

/// 快进快退View
@property (nonatomic, strong, readonly) UIView *fastForwardRewindView;

/// 快进快退进度progress
@property (nonatomic, strong, readonly) YBPlayerSliderView *fastForwardRewindProgressView;

/// 快进快退时间
@property (nonatomic, strong, readonly) UILabel *fastForwardRewindTimeLabel;

/// 快进快退ImageView
@property (nonatomic, strong, readonly) UIImageView *fastForwardRewindImageView;

/// 加载失败按钮
@property (nonatomic, strong, readonly) UIButton *loadFailedButton;

/// 底部播放进度
@property (nonatomic, strong, readonly) YBPlayerSliderView *bottomEdgeProgressView;

/// 封面图
@property (nonatomic, strong, readonly) UIImageView *coverImageView;

/// 高斯模糊的背景图
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

/// 高斯模糊视图
@property (nonatomic, strong, readonly) __kindof UIView *blurEffectView;

/// 小窗口控制层
@property (nonatomic, strong, readonly) YBPlayerFloatingControlView *floatingControlView;

/// 控制层场景, 默认 YBPlayerControlViewSceneOthers
@property (nonatomic, assign) YBPlayerControlViewScene viewScene;

/// 快进视图是否显示动画，默认NO.
@property (nonatomic, assign) BOOL shouldAnimateFastForwardRewind;

/// 是否显示底部边缘进度条， 默认NO
@property (nonatomic, assign) BOOL displayBottomEdgeProgressView;

/// 视频之外区域是否高斯模糊显示，默认NO.
@property (nonatomic, assign) BOOL shouldDisplayBlurEffectView;

/// 直接进入全屏模式，只支持全屏模式
@property (nonatomic, assign) BOOL fullScreenModeOnly;

/// 如果是暂停状态，seek完是否播放，默认YES
@property (nonatomic, assign) BOOL seekAfterPlay;

/// 返回按钮点击回调
@property (nonatomic, copy) void(^backButtonClickCallback)(void);

/// 控制层显示或者隐藏
@property (nonatomic, readonly) BOOL controlViewAppeared;

/// 控制层显示或者隐藏的回调
@property (nonatomic, copy) void(^controlViewAppearedCallback)(BOOL appeared);

/// 控制层自动隐藏的时间，默认2.5秒
@property (nonatomic, assign) NSTimeInterval autoHiddenTimeInterval;

/// 控制层显示、隐藏动画的时长，默认0.25秒
@property (nonatomic, assign) NSTimeInterval autoFadeTimeInterval;

/// 横向滑动控制播放进度时是否显示控制层,默认 YES.
@property (nonatomic, assign) BOOL dispayControlViewWhenHorizontalPanGestureRecognized;

/// prepare时候是否显示控制层,默认 NO.
@property (nonatomic, assign) BOOL dispayControlViewWhenPlayerPrepared;

/// prepare时候是否显示loading,默认 NO.
@property (nonatomic, assign) BOOL dispayLoadingViewWhenPlayerPrepared;

/// 是否自定义禁止pan手势，默认 NO.
@property (nonatomic, assign) BOOL disablePanGestureMovingDirection;

/**
 设置标题、封面、全屏模式

 @param title 视频的标题
 @param coverUrl 视频的封面，占位图默认是灰色的
 @param fullScreenMode 全屏模式
 */
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fullScreenMode:(YBFullScreenMode)fullScreenMode;

/**
 设置标题、封面、默认占位图、全屏模式

 @param title 视频的标题
 @param coverUrl 视频的封面
 @param placeholder 指定封面的placeholder
 @param fullScreenMode 全屏模式
 */
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fullScreenMode:(YBFullScreenMode)fullScreenMode;

/**
 设置标题、UIImage封面、全屏模式

 @param title 视频的标题
 @param image 视频的封面UIImage
 @param fullScreenMode 全屏模式
 */
- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fullScreenMode:(YBFullScreenMode)fullScreenMode;

/**
 重置控制层
 */
- (void)resetControlView;

@end

NS_ASSUME_NONNULL_END
