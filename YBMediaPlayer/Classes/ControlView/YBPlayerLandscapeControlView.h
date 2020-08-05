//
//  YBPlayerLandscapeControlView.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBPlayerSliderView.h"
#import "YBPlayerLandscapeSideView.h"
#if __has_include(<YBMediaPlayer/YBPlayerController.h>)
#import <YBMediaPlayer/YBPlayerController.h>
#else
#import "YBPlayerController.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface YBPlayerLandscapeControlView : UIView

/// 顶部工具栏
@property (nonatomic, strong, readonly) UIView *topToolView;
/// 返回按钮
@property (nonatomic, strong, readonly) UIButton *backButton;
/// 标题
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 中间工具栏
@property (nonatomic, strong, readonly) UIView *middleToolView;
/// 播放或暂停按钮
@property (nonatomic, strong, readonly) UIButton *playOrPauseButton;
/// 上一曲按钮
@property (nonatomic, strong, readonly) UIButton *previousButton;
/// 下一曲按钮
@property (nonatomic, strong, readonly) UIButton *nextButton;

/// 底部工具栏
@property (nonatomic, strong, readonly) UIView *bottomToolView;
/// 播放的当前时间
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong, readonly) YBPlayerSliderView *slider;
/// 视频总时间
@property (nonatomic, strong, readonly) UILabel *totalTimeLabel;
/// 倍速按钮
@property (nonatomic, strong, readonly) UIButton *rateButton;
/// 选择章节按钮
@property (nonatomic, strong, readonly) UIButton *chapterSelectionButton;

/// 锁定屏幕按钮
@property (nonatomic, strong, readonly) UIButton *lockerButton;

/// 侧边速率选择视图
@property (nonatomic, strong, readonly) YBPlayerLandscapeSideView *sideRateSelectionView;

/// 侧边章节选择视图
@property (nonatomic, strong, readonly) YBPlayerLandscapeSideView *sideChapterSelectionView;

/// 是否显示侧边速率择视图
@property (nonatomic, assign) BOOL shouldShowSideRateSelectionView;

/// 是否显示侧边章节选择视图
@property (nonatomic, assign) BOOL shouldShowSideChapterSelectionView;

/// 播放器
@property (nonatomic, weak) YBPlayerController *player;

/// slider滑动中
@property (nonatomic, copy, nullable) void(^sliderValueChanging)(CGFloat value,BOOL isForwarding);

/// slider滑动结束
@property (nonatomic, copy, nullable) void(^sliderValueChanged)(CGFloat value);


/// 返回按钮点击回调
@property (nonatomic, copy) void(^backButtonClickCallback)(void);

/// 如果是暂停状态，seek完是否播放，默认YES
@property (nonatomic, assign) BOOL seekAfterPlay;

/// 重置控制层
- (void)resetControlView;

/// 显示控制层
- (void)showControlView;

/// 隐藏控制层
- (void)hideControlView;

/// 设置播放时间
- (void)videoPlayer:(YBPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

/// 播放器已经设置了资源 URLs
/// @param videoPlayer 播放器
/// @param didPlayFirstAsset 播放第一节
/// @param didPlayLastAsset 播放最后一节
/// @param assetURLs 资源地址集合
- (void)videoPlayer:(YBPlayerController *)videoPlayer didPlayFirstAsset:(BOOL)didPlayFirstAsset didPlayLastAsset:(BOOL)didPlayLastAsset assetURLs:(NSArray <NSURL *> *)assetURLs;

/// 设置缓冲时间
- (void)videoPlayer:(YBPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime;

/// 是否响应该手势
- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(YBPlayerGestureType)type touch:(nonnull UITouch *)touch;

/// 视频尺寸改变
- (void)videoPlayer:(YBPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size;

/// 标题和全屏模式
- (void)showTitle:(NSString *_Nullable)title fullScreenMode:(YBFullScreenMode)fullScreenMode;

/// 根据当前播放状态取反
- (void)playOrPause;

/// 播放按钮状态
- (void)playButtonSelection:(BOOL)selected;

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString;

/// 滑杆结束滑动
- (void)sliderChangeEnded;

/// dismiss 侧边速率选择视图
- (void)dismissSideRateSelectionView;
/// dismiss 侧边章节选择视图
- (void)dismissSideChapterSelectionView;

@end

NS_ASSUME_NONNULL_END
