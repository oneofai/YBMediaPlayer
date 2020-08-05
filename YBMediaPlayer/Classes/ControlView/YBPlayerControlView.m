//
//  YBNetworkSpeedMonitor.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerControlView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+YBFrame.h"
#import "YBPlayerSliderView.h"
#import "UIImageView+YBWebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YBPlayerVolumeView.h"
#import "YBPlayerControlViewUtilities.h"
#if __has_include(<YBMediaPlayer/YBMediaPlayer.h>)
#import <YBMediaPlayer/YBMediaPlayer.h>
#else
#import "YBMediaPlayer.h"
#endif

@interface YBPlayerControlView () <YBPlayerSliderViewDelegate>
/// 竖屏控制层的View
@property (nonatomic, strong) YBPlayerPortraitControlView *portraitControlView;
/// 横屏控制层的View
@property (nonatomic, strong) YBPlayerLandscapeControlView *landscapeControlView;
/// 加载loading
@property (nonatomic, strong) YBPlayerSpeedLoadingView *activity;
/// 快进快退View
@property (nonatomic, strong) UIView *fastForwardRewindView;
/// 快进快退进度progress
@property (nonatomic, strong) YBPlayerSliderView *fastForwardRewindProgressView;
/// 快进快退时间
@property (nonatomic, strong) UILabel *fastForwardRewindTimeLabel;
/// 快进快退ImageView
@property (nonatomic, strong) UIImageView *fastForwardRewindImageView;
/// 加载失败按钮
@property (nonatomic, strong) UIButton *loadFailedButton;
/// 底部播放进度
@property (nonatomic, strong) YBPlayerSliderView *bottomEdgeProgressView;
/// 封面图
@property (nonatomic, strong) UIImageView *coverImageView;
/// 是否显示了控制层
@property (nonatomic, assign, getter=isShowing) BOOL showing;
/// 是否播放结束
@property (nonatomic, assign, getter=isPlayEnd) BOOL playeEnd;

@property (nonatomic, assign) BOOL controlViewAppeared;

@property (nonatomic, assign) NSTimeInterval sumTime;

@property (nonatomic, strong) dispatch_block_t afterBlock;

@property (nonatomic, strong) YBPlayerFloatingControlView *floatingControlView;

@property (nonatomic, strong) YBPlayerVolumeView *volumeBrightnessView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) __kindof UIView *blurEffectView;

@end

@implementation YBPlayerControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllSubViews];
        self.landscapeControlView.hidden = YES;
        self.displayBottomEdgeProgressView = NO;
        self.viewScene = YBPlayerControlViewSceneOthers;
        self.floatingControlView.hidden = YES;
        self.seekAfterPlay = YES;
        self.shouldDisplayBlurEffectView = NO;
        self.dispayControlViewWhenHorizontalPanGestureRecognized = YES;
        self.autoFadeTimeInterval = 0.25;
        self.autoHiddenTimeInterval = 2.5;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.yb_width;
    CGFloat min_view_h = self.yb_height;
    
    self.portraitControlView.frame = self.bounds;
    self.landscapeControlView.frame = self.bounds;
    self.floatingControlView.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    self.backgroundImageView.frame = self.bounds;
    self.blurEffectView.frame = self.bounds;
    
    min_w = 80;
    min_h = 80;
    self.activity.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.activity.yb_centerX = self.yb_centerX;
    self.activity.yb_centerY = self.yb_centerY + 10;
    
    min_w = 150;
    min_h = 30;
    self.loadFailedButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.loadFailedButton.center = self.center;
    
    min_w = 140;
    min_h = 80;
    self.fastForwardRewindView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fastForwardRewindView.center = self.center;
    
    min_w = 32;
    min_x = (self.fastForwardRewindView.yb_width - min_w) / 2;
    min_y = 5;
    min_h = 32;
    self.fastForwardRewindImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = self.fastForwardRewindImageView.yb_bottom + 2;
    min_w = self.fastForwardRewindView.yb_width;
    min_h = 20;
    self.fastForwardRewindTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 12;
    min_y = self.fastForwardRewindTimeLabel.yb_bottom + 5;
    min_w = self.fastForwardRewindView.yb_width - 2 * min_x;
    min_h = 10;
    self.fastForwardRewindProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = min_view_h - 1;
    min_w = min_view_w;
    min_h = 1;
    self.bottomEdgeProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 30;
    if (self.player.isFullScreen) {
        min_y = 44;
    }
    min_w = 170;
    min_h = 35;
    self.volumeBrightnessView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.volumeBrightnessView.yb_centerX = self.yb_centerX;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self cancelAutoFadeOutControlView];
}

/// 添加所有子控件
- (void)addAllSubViews {
    [self addSubview:self.portraitControlView];
    [self addSubview:self.landscapeControlView];
    [self addSubview:self.floatingControlView];
    [self addSubview:self.activity];
    [self addSubview:self.loadFailedButton];
    [self addSubview:self.fastForwardRewindView];
    [self.fastForwardRewindView addSubview:self.fastForwardRewindImageView];
    [self.fastForwardRewindView addSubview:self.fastForwardRewindTimeLabel];
    [self.fastForwardRewindView addSubview:self.fastForwardRewindProgressView];
    [self addSubview:self.bottomEdgeProgressView];
    [self addSubview:self.volumeBrightnessView];
}

- (void)autoFadeOutControlView {
    self.controlViewAppeared = YES;
    [self cancelAutoFadeOutControlView];
    @weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @strongify(self)
        [self hideControlViewWithAnimated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoHiddenTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

/// 取消延时隐藏controlView的方法
- (void)cancelAutoFadeOutControlView {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

/// 隐藏控制层
- (void)hideControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = NO;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(NO);
    }
    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 animations:^{
        if (self.player.isFullScreen) {
            [self.landscapeControlView hideControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView hideControlView];
            }
        }
    } completion:^(BOOL finished) {
        if (self.displayBottomEdgeProgressView) {
            self.bottomEdgeProgressView.hidden = NO;
        }
    }];
}

/// 显示控制层
- (void)showControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = YES;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(YES);
    }
    [self autoFadeOutControlView];
    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 animations:^{
        if (self.player.isFullScreen) {
            [self.landscapeControlView showControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView showControlView];
            }
        }
    } completion:^(BOOL finished) {
        if (self.displayBottomEdgeProgressView) {
            self.bottomEdgeProgressView.hidden = YES;
        }
    }];
}

/// 音量改变的通知
- (void)volumeChanged:(NSNotification *)notification {    
    NSDictionary *userInfo = notification.userInfo;
    NSString *reasonstr = userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([reasonstr isEqualToString:@"ExplicitVolumeChange"]) {
        float volume = [ userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        if (self.player.isFullScreen) {
            [self.volumeBrightnessView updateProgress:volume volumeType:YBPlayerVolumeTypeSonic];
        } else {
            [self.volumeBrightnessView addSystemVolumeView];
        }
    }
}

#pragma mark - Public Method

/// 重置控制层
- (void)resetControlView {
    //TODO: 根据viewScene 设置不同的控件样式
    
    switch (self.viewScene) {
        case YBPlayerControlViewSceneBookVideo:
            
            break;
        case YBPlayerControlViewSceneSmalltalk:
            
            break;
        case YBPlayerControlViewSceneBusinessSchool:
            self.portraitControlView.previousButton.hidden = YES;
            self.portraitControlView.nextButton.hidden = YES;
            self.portraitControlView.topToolView.hidden = YES;
            self.portraitControlView.slider.sliderButton.hidden = NO;
            self.portraitControlView.slider.allowTapped = YES;
            self.portraitControlView.slider.allowSliderSliding = YES;
            
            self.landscapeControlView.previousButton.hidden = YES;
            self.landscapeControlView.nextButton.hidden = YES;
            self.landscapeControlView.topToolView.hidden = NO;
            self.landscapeControlView.slider.sliderButton.hidden = NO;
            self.landscapeControlView.slider.allowTapped = YES;
            self.landscapeControlView.slider.allowSliderSliding = YES;
            
            self.landscapeControlView.shouldShowSideRateSelectionView = NO;
            self.landscapeControlView.shouldShowSideChapterSelectionView = NO;
            self.landscapeControlView.chapterSelectionButton.hidden = YES;
            self.landscapeControlView.rateButton.hidden = YES;
            
            /// 禁用滑动手势
//            self.disablePanGestureMovingDirection = YES;
//            self.player.disablePanMovingDirection = YBPlayerDisablePanMovingDirectionHorizontal;
//            self.player.disableGestureTypes = YBPlayerDisableGestureTypesLongPress;
            
            self.displayBottomEdgeProgressView = NO;
            break;
        default:
            break;
    }
    
    [self _internalResetControlView];
}

- (void)_internalResetControlView {
    [self.portraitControlView resetControlView];
    [self.landscapeControlView resetControlView];
    [self cancelAutoFadeOutControlView];
    self.bottomEdgeProgressView.value = 0;
    self.bottomEdgeProgressView.bufferValue = 0;
    self.bottomEdgeProgressView.hidden = !self.displayBottomEdgeProgressView;
    self.floatingControlView.hidden = YES;
    self.loadFailedButton.hidden = YES;
    self.volumeBrightnessView.hidden = YES;
    self.portraitControlView.hidden = self.player.isFullScreen;
    self.landscapeControlView.hidden = !self.player.isFullScreen;
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

/// 设置标题、封面、全屏模式
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fullScreenMode:(YBFullScreenMode)fullScreenMode {
    UIImage *placeholder = [YBPlayerControlViewUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:self.backgroundImageView.bounds.size];
    [self showTitle:title coverURLString:coverUrl placeholderImage:placeholder fullScreenMode:fullScreenMode];
}

/// 设置标题、封面、默认占位图、全屏模式
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fullScreenMode:(YBFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landscapeControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.coverImageView setImageWithURLString:coverUrl placeholder:placeholder];
    [self.backgroundImageView setImageWithURLString:coverUrl placeholder:placeholder];
    if (self.dispayControlViewWhenPlayerPrepared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

/// 设置标题、UIImage封面、全屏模式
- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fullScreenMode:(YBFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landscapeControlView showTitle:title fullScreenMode:fullScreenMode];
    self.coverImageView.image = image;
    self.backgroundImageView.image = image;
    if (self.dispayControlViewWhenPlayerPrepared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

#pragma mark - YBPlayerControlViewDelegate

/// 手势筛选，返回NO不响应该手势
- (BOOL)gestureTriggerCondition:(YBPlayerGestureControl *)gestureControl gestureType:(YBPlayerGestureType)gestureType gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(nonnull UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen && gestureType != YBPlayerGestureTypeSingleTap) {
        return NO;
    }
    if (self.player.isFullScreen) {
        /// 不禁用滑动方向
        if (!self.disablePanGestureMovingDirection) {
            self.player.disablePanMovingDirection = YBPlayerDisablePanMovingDirectionNone;
        }
        return [self.landscapeControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    } else {
        /// 不禁用滑动方向
        if (!self.disablePanGestureMovingDirection) {
            if (self.player.scrollView) {  /// 列表时候禁止上下滑动（防止和列表滑动冲突）
                self.player.disablePanMovingDirection = YBPlayerDisablePanMovingDirectionVertical;
            } else { /// 不禁用滑动方向
                self.player.disablePanMovingDirection = YBPlayerDisablePanMovingDirectionNone;
            }
        }
        return [self.portraitControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    }
}

/// 单击手势事件
- (void)gestureSingleTapped:(YBPlayerGestureControl *)gestureControl {
    if (!self.player) return;
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen) {
        [self.player enterFullScreen:YES animated:YES];
    } else {
        if (self.controlViewAppeared) {
            [self hideControlViewWithAnimated:YES];
        } else {
            /// 显示之前先把控制层复位，先隐藏后显示
            [self hideControlViewWithAnimated:NO];
            [self showControlViewWithAnimated:YES];
        }
    }
}

/// 双击手势事件
- (void)gestureDoubleTapped:(YBPlayerGestureControl *)gestureControl {
    if (self.player.isFullScreen) {
        [self.landscapeControlView playOrPause];
    } else {
        [self.portraitControlView playOrPause];
    }
}

/// 开始滑动手势事件
- (void)gestureBeganPan:(YBPlayerGestureControl *)gestureControl panDirection:(YBPanDirection)direction panLocation:(YBPanLocation)location {
    if (direction == YBPanDirectionH) {
        self.sumTime = self.player.currentTime;
    }
}

/// 滑动中手势事件
- (void)gestureChangedPan:(YBPlayerGestureControl *)gestureControl panDirection:(YBPanDirection)direction panLocation:(YBPanLocation)location withVelocity:(CGPoint)velocity {
    if (direction == YBPanDirectionH) {
        // 每次滑动需要叠加时间
        self.sumTime += velocity.x / 200;
        // 需要限定sumTime的范围
        NSTimeInterval totalMovieDuration = self.player.totalTime;
        if (totalMovieDuration == 0) return;
        if (self.sumTime > totalMovieDuration) self.sumTime = totalMovieDuration;
        if (self.sumTime < 0) self.sumTime = 0;
        BOOL style = NO;
        if (velocity.x > 0) style = YES;
        if (velocity.x < 0) style = NO;
        if (velocity.x == 0) return;
        [self sliderValueChangingValue:self.sumTime/totalMovieDuration isForwarding:style];
    } else if (direction == YBPanDirectionV) {
        if (location == YBPanLocationLeft) { /// 调节亮度
            self.player.brightness -= (velocity.y) / 10000;
            [self.volumeBrightnessView updateProgress:self.player.brightness volumeType:YBPlayerVolumeTypeumeBrightness];
        } else if (location == YBPanLocationRight) { /// 调节声音
            self.player.volume -= (velocity.y) / 10000;
//            if (self.player.isFullScreen) {
                [self.volumeBrightnessView updateProgress:self.player.volume volumeType:YBPlayerVolumeTypeSonic];
//            }
        }
    }
}

/// 滑动结束手势事件
- (void)gestureEndedPan:(YBPlayerGestureControl *)gestureControl panDirection:(YBPanDirection)direction panLocation:(YBPanLocation)location {
    @weakify(self)
    if (direction == YBPanDirectionH && self.sumTime >= 0 && self.player.totalTime > 0) {
        [self.player seekToTime:self.sumTime completionHandler:^(BOOL finished) {
            @strongify(self)
            /// 左右滑动调节播放进度
            [self.portraitControlView sliderChangeEnded];
            [self.landscapeControlView sliderChangeEnded];
            if (self.controlViewAppeared) {
                [self autoFadeOutControlView];
            }
        }];
        if (self.seekAfterPlay) {
            [self.player.currentPlayerManager play];
        }
        self.sumTime = 0;
    }
}

/// 捏合手势事件，这里改变了视频的填充模式
- (void)gesturePinched:(YBPlayerGestureControl *)gestureControl scale:(float)scale {
    if (scale > 1) {
        self.player.currentPlayerManager.scalingMode = YBPlayerScalingModeAspectFill;
    } else {
        self.player.currentPlayerManager.scalingMode = YBPlayerScalingModeAspectFit;
    }
}

/// 准备播放
- (void)videoPlayer:(YBPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL {
    [self hideControlViewWithAnimated:NO];
}

/// 播放状态改变
- (void)videoPlayer:(YBPlayerController *)videoPlayer playStateChanged:(YBPlayerPlaybackState)state {
    if (state == YBPlayerPlayStatePlaying) {
        [self.portraitControlView playButtonSelection:YES];
        [self.landscapeControlView playButtonSelection:YES];
        self.loadFailedButton.hidden = YES;
        /// 开始播放时候判断是否显示loading
        if (videoPlayer.currentPlayerManager.loadState == YBPlayerLoadStateStalled && !self.dispayLoadingViewWhenPlayerPrepared) {
            [self.activity startAnimating];
        } else if ((videoPlayer.currentPlayerManager.loadState == YBPlayerLoadStateStalled || videoPlayer.currentPlayerManager.loadState == YBPlayerLoadStatePrepare) && self.dispayLoadingViewWhenPlayerPrepared) {
            [self.activity startAnimating];
        }
    } else if (state == YBPlayerPlayStatePaused) {
        [self.portraitControlView playButtonSelection:NO];
        [self.landscapeControlView playButtonSelection:NO];
        /// 暂停的时候隐藏loading
        [self.activity stopAnimating];
        self.loadFailedButton.hidden = YES;
    } else if (state == YBPlayerPlayStatePlayFailed) {
        self.loadFailedButton.hidden = NO;
        [self.activity stopAnimating];
    }
}

/// 加载状态改变
- (void)videoPlayer:(YBPlayerController *)videoPlayer loadStateChanged:(YBPlayerLoadState)state {
    if (state == YBPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
        [self.portraitControlView playButtonSelection:videoPlayer.currentPlayerManager.shouldAutoPlay];
        [self.landscapeControlView playButtonSelection:videoPlayer.currentPlayerManager.shouldAutoPlay];
    } else if (state == YBPlayerLoadStatePlaythroughOK || state == YBPlayerLoadStatePlayable) {
        self.coverImageView.hidden = YES;
        if (self.shouldDisplayBlurEffectView) {
            self.blurEffectView.hidden = NO;
        } else {
            self.blurEffectView.hidden = YES;
            self.player.currentPlayerManager.view.backgroundColor = [UIColor blackColor];
        }
    }
    if (state == YBPlayerLoadStateStalled && videoPlayer.currentPlayerManager.isPlaying && !self.dispayLoadingViewWhenPlayerPrepared) {
        [self.activity startAnimating];
    } else if ((state == YBPlayerLoadStateStalled || state == YBPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.isPlaying && self.dispayLoadingViewWhenPlayerPrepared) {
        [self.activity startAnimating];
    } else {
        [self.activity stopAnimating];
    }
}

/// 播放进度改变回调
- (void)videoPlayer:(YBPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [self.portraitControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    [self.landscapeControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    self.bottomEdgeProgressView.value = videoPlayer.progress;
}

/// 缓冲改变回调
- (void)videoPlayer:(YBPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    [self.portraitControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    [self.landscapeControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    self.bottomEdgeProgressView.bufferValue = videoPlayer.bufferProgress;
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
    [self.landscapeControlView videoPlayer:videoPlayer presentationSizeChanged:size];
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer didPlayFirstAsset:(BOOL)didPlayFirstAsset didPlayLastAsset:(BOOL)didPlayLastAsset assetURLs:(nonnull NSArray<NSURL *> *)assetURLs {
    [self.portraitControlView videoPlayer:videoPlayer
                        didPlayFirstAsset:didPlayFirstAsset
                         didPlayLastAsset:didPlayLastAsset
                                assetURLs:assetURLs];
    
    [self.landscapeControlView videoPlayer:videoPlayer
                         didPlayFirstAsset:didPlayFirstAsset
                          didPlayLastAsset:didPlayLastAsset
                                 assetURLs:assetURLs];
}

/// 视频view即将旋转
- (void)videoPlayer:(YBPlayerController *)videoPlayer orientationWillChange:(YBPlayerOrientationObserver *)observer {
    self.portraitControlView.hidden = observer.isFullScreen;
    self.landscapeControlView.hidden = !observer.isFullScreen;
    if (videoPlayer.isSmallFloatViewShow) {
        self.floatingControlView.hidden = observer.isFullScreen;
        self.portraitControlView.hidden = YES;
        if (observer.isFullScreen) {
            self.controlViewAppeared = NO;
            [self cancelAutoFadeOutControlView];
        }
    }
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
    
    if (observer.isFullScreen) {
        [self.volumeBrightnessView removeSystemVolumeView];
    } else {
        [self.volumeBrightnessView addSystemVolumeView];
        
        [self.landscapeControlView dismissSideRateSelectionView];
        [self.landscapeControlView dismissSideChapterSelectionView];
    }
}

/// 视频view已经旋转
- (void)videoPlayer:(YBPlayerController *)videoPlayer orientationDidChanged:(YBPlayerOrientationObserver *)observer {
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

/// 锁定旋转方向
- (void)lockedVideoPlayer:(YBPlayerController *)videoPlayer lockedScreen:(BOOL)locked {
    [self showControlViewWithAnimated:YES];
}

/// 列表滑动时视频view已经显示
- (void)playerDidAppearInScrollView:(YBPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatingControlView.hidden = YES;
        self.portraitControlView.hidden = NO;
    }
}

/// 列表滑动时视频view已经消失
- (void)playerDidDisappearInScrollView:(YBPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatingControlView.hidden = NO;
        self.portraitControlView.hidden = YES;
    }
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer floatViewShow:(BOOL)show {
    self.floatingControlView.hidden = !show;
    self.portraitControlView.hidden = show;
}



#pragma mark - Private Method

- (void)sliderValueChangingValue:(CGFloat)value isForwarding:(BOOL)isForwarding {
    if (self.dispayControlViewWhenHorizontalPanGestureRecognized) {
        /// 显示控制层
        [self showControlViewWithAnimated:NO];
        [self cancelAutoFadeOutControlView];
    }
    
    self.fastForwardRewindProgressView.value = value;
    self.fastForwardRewindView.hidden = NO;
    self.fastForwardRewindView.alpha = 1;
    if (isForwarding) {
        self.fastForwardRewindImageView.image = YBUIImageMake(@"YBPlayer_fast_forward");
    } else {
        self.fastForwardRewindImageView.image = YBUIImageMake(@"YBPlayer_fast_backward");
    }
    NSString *draggedTime = [YBPlayerControlViewUtilities convertTimeSecond:self.player.totalTime*value];
    NSString *totalTime = [YBPlayerControlViewUtilities convertTimeSecond:self.player.totalTime];
    self.fastForwardRewindTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",draggedTime,totalTime];
    /// 更新滑杆
    [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
    [self.landscapeControlView sliderValueChanged:value currentTimeString:draggedTime];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFastForwardRewindView) object:nil];
    [self performSelector:@selector(hideFastForwardRewindView) withObject:nil afterDelay:0.1];
    
    if (self.shouldAnimateFastForwardRewind) {
        [UIView animateWithDuration:0.35 animations:^{
            self.fastForwardRewindView.transform = CGAffineTransformMakeTranslation(isForwarding ? 8 : -8, 0);
        }];
    }
}

/// 隐藏快进视图
- (void)hideFastForwardRewindView {
    [UIView animateWithDuration:0.4 animations:^{
        self.fastForwardRewindView.transform = CGAffineTransformIdentity;
        self.fastForwardRewindView.alpha = 0;
    } completion:^(BOOL finished) {
        self.fastForwardRewindView.hidden = YES;
    }];
}

/// 加载失败
- (void)loadFailedButtonClick:(UIButton *)sender {
    [self.player.currentPlayerManager reloadPlayer];
}


#pragma mark - setter

- (void)setPlayer:(YBPlayerController *)player {
    _player = player;
    self.landscapeControlView.player = player;
    self.portraitControlView.player = player;
    /// 解决播放时候黑屏闪一下问题
    [player.currentPlayerManager.view insertSubview:self.backgroundImageView atIndex:0];
    [self.backgroundImageView addSubview:self.blurEffectView];
    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:1];
    self.coverImageView.frame = player.currentPlayerManager.view.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView.frame = player.currentPlayerManager.view.bounds;
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurEffectView.frame = self.backgroundImageView.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSeekAfterPlay:(BOOL)seekAfterPlay {
    _seekAfterPlay = seekAfterPlay;
    self.portraitControlView.seekAfterPlay = seekAfterPlay;
    self.landscapeControlView.seekAfterPlay = seekAfterPlay;
}

- (void)setShouldDisplayBlurEffectView:(BOOL)shouldDisplayBlurEffectView {
    _shouldDisplayBlurEffectView = shouldDisplayBlurEffectView;
    if (shouldDisplayBlurEffectView) {
        self.backgroundImageView.hidden = NO;
    } else {
        self.backgroundImageView.hidden = YES;
    }
}

- (void)setViewScene:(YBPlayerControlViewScene)viewScene {
    _viewScene = viewScene;
    [self resetControlView];
}

#pragma mark - getter

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.userInteractionEnabled = YES;
    }
    return _backgroundImageView;
}

- (UIView *)blurEffectView {
    if (!_blurEffectView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            UIToolbar *blurEffectView = [[UIToolbar alloc] init];
            blurEffectView.barStyle = UIBarStyleBlackTranslucent;
            _blurEffectView = blurEffectView;
        }
    }
    return _blurEffectView;
}

- (YBPlayerPortraitControlView *)portraitControlView {
    if (!_portraitControlView) {
        @weakify(self)
        _portraitControlView = [[YBPlayerPortraitControlView alloc] init];
        _portraitControlView.sliderValueChanging = ^(CGFloat value, BOOL isForwarding) {
            @strongify(self)
            [self cancelAutoFadeOutControlView];
        };
        _portraitControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
            [self autoFadeOutControlView];
        };
    }
    return _portraitControlView;
}

- (YBPlayerLandscapeControlView *)landscapeControlView {
    if (!_landscapeControlView) {
        @weakify(self)
        _landscapeControlView = [[YBPlayerLandscapeControlView alloc] init];
        _landscapeControlView.sliderValueChanging = ^(CGFloat value, BOOL isForwarding) {
            @strongify(self)
            [self cancelAutoFadeOutControlView];
        };
        _landscapeControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
            [self autoFadeOutControlView];
        };
    }
    return _landscapeControlView;
}

- (YBPlayerSpeedLoadingView *)activity {
    if (!_activity) {
        _activity = [[YBPlayerSpeedLoadingView alloc] init];
    }
    return _activity;
}

- (UIView *)fastForwardRewindView {
    if (!_fastForwardRewindView) {
        _fastForwardRewindView = [[UIView alloc] init];
        _fastForwardRewindView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _fastForwardRewindView.layer.cornerRadius = 4;
        _fastForwardRewindView.layer.masksToBounds = YES;
        _fastForwardRewindView.hidden = YES;
    }
    return _fastForwardRewindView;
}

- (UIImageView *)fastForwardRewindImageView {
    if (!_fastForwardRewindImageView) {
        _fastForwardRewindImageView = [[UIImageView alloc] init];
    }
    return _fastForwardRewindImageView;
}

- (UILabel *)fastForwardRewindTimeLabel {
    if (!_fastForwardRewindTimeLabel) {
        _fastForwardRewindTimeLabel = [[UILabel alloc] init];
        _fastForwardRewindTimeLabel.textColor = [UIColor whiteColor];
        _fastForwardRewindTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastForwardRewindTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _fastForwardRewindTimeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _fastForwardRewindTimeLabel;
}

- (YBPlayerSliderView *)fastForwardRewindProgressView {
    if (!_fastForwardRewindProgressView) {
        _fastForwardRewindProgressView = [[YBPlayerSliderView alloc] init];
        _fastForwardRewindProgressView.maximumTrackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        _fastForwardRewindProgressView.minimumTrackTintColor = [UIColor whiteColor];
        _fastForwardRewindProgressView.sliderBarHeight = 2;
        _fastForwardRewindProgressView.hiddenSliderButton = NO;
    }
    return _fastForwardRewindProgressView;
}

- (UIButton *)loadFailedButton {
    if (!_loadFailedButton) {
        _loadFailedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_loadFailedButton setTitle:@"加载失败, 点击重试" forState:UIControlStateNormal];
        [_loadFailedButton addTarget:self action:@selector(loadFailedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_loadFailedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loadFailedButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _loadFailedButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _loadFailedButton.hidden = YES;
    }
    return _loadFailedButton;
}

- (YBPlayerSliderView *)bottomEdgeProgressView {
    if (!_bottomEdgeProgressView) {
        _bottomEdgeProgressView = [[YBPlayerSliderView alloc] init];
        _bottomEdgeProgressView.maximumTrackTintColor = [UIColor clearColor];
        _bottomEdgeProgressView.minimumTrackTintColor = [UIColor whiteColor];
        _bottomEdgeProgressView.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomEdgeProgressView.sliderBarHeight = 1;
        _bottomEdgeProgressView.hiddenSliderButton = NO;
        _bottomEdgeProgressView.hidden = YES;
    }
    return _bottomEdgeProgressView;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (YBPlayerFloatingControlView *)floatingControlView {
    if (!_floatingControlView) {
        _floatingControlView = [[YBPlayerFloatingControlView alloc] init];
        @weakify(self)
        _floatingControlView.closeButtonTappedHandler = ^{
            @strongify(self)
            if (self.player.containerType == YBPlayerContainerTypeCell) {
                [self.player stopCurrentPlayingCell];
            } else if (self.player.containerType == YBPlayerContainerTypeView) {
                [self.player stopCurrentPlayingView];
            }
            [self resetControlView];
        };
    }
    return _floatingControlView;
}

- (YBPlayerVolumeView *)volumeBrightnessView {
    if (!_volumeBrightnessView) {
        _volumeBrightnessView = [[YBPlayerVolumeView alloc] init];
        _volumeBrightnessView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    return _volumeBrightnessView;
}

- (void)setBackButtonClickCallback:(void (^)(void))backButtonClickCallback {
    _backButtonClickCallback = [backButtonClickCallback copy];
    self.landscapeControlView.backButtonClickCallback = _backButtonClickCallback;
}

@end
