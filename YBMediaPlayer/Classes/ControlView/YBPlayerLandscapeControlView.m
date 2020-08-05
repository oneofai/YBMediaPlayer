//
//  YBPlayerLandscapeControlView.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerLandscapeControlView.h"
#import "UIView+YBFrame.h"
#import "YBPlayerControlViewUtilities.h"
#if __has_include(<YBMediaPlayer/YBMediaPlayer.h>)
#import <YBMediaPlayer/YBMediaPlayer.h>
#else
#import "YBMediaPlayer.h"
#endif

@interface YBPlayerLandscapeControlView () <YBPlayerSliderViewDelegate>
/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
/// 返回按钮
@property (nonatomic, strong) UIButton *backButton;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;

/// 中间工具栏
@property (nonatomic, strong) UIView *middleToolView;
/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseButton;
/// 上一曲按钮
@property (nonatomic, strong) UIButton *previousButton;
/// 下一曲按钮
@property (nonatomic, strong) UIButton *nextButton;

/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;
/// 播放的当前时间 
@property (nonatomic, strong) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong) YBPlayerSliderView *slider;
/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
/// 倍速按钮
@property (nonatomic, strong) UIButton *rateButton;
/// 选择章节按钮
@property (nonatomic, strong) UIButton *chapterSelectionButton;

/// 锁定屏幕按钮
@property (nonatomic, strong) UIButton *lockerButton;

/// 侧边速率视图
@property (nonatomic, strong) YBPlayerLandscapeSideView *sideRateSelectionView;

/// 侧边章节选择视图
@property (nonatomic, strong) YBPlayerLandscapeSideView *sideChapterSelectionView;

/// 侧边速率择视图是否正在显示
@property (nonatomic, assign) BOOL isSideRateSelectionViewShowing;

/// 侧边章节选择视图是否正在显示
@property (nonatomic, assign) BOOL isSideChapterSelectionViewShowing;

/// 控制视图是否正在显示
@property (nonatomic, assign) BOOL isShow;

/// 播放器原手势
@property (nonatomic, assign) YBPlayerDisableGestureTypes originalTypes;

@end

@implementation YBPlayerLandscapeControlView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.topToolView];
        [self.topToolView addSubview:self.backButton];
        [self.topToolView addSubview:self.titleLabel];
        
        [self addSubview:self.middleToolView];
        [self.middleToolView addSubview:self.playOrPauseButton];
        [self.middleToolView addSubview:self.previousButton];
        [self.middleToolView addSubview:self.nextButton];
        
        [self addSubview:self.bottomToolView];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.rateButton];
        [self.bottomToolView addSubview:self.chapterSelectionButton];
        
        [self addSubview:self.lockerButton];
        
        [self addSubview:self.sideRateSelectionView];
        [self addSubview:self.sideChapterSelectionView];
        
        // 设置子控件的响应事件
        [self makeSubviewsAction];
        [self resetControlView];
        
        /// statusBarFrame changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layOutControllerViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGFloat min_margin = 8;
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = SafeAreaInsetsForDevice.top + 70;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = SafeAreaInsetsForDevice.left + min_margin;
    min_y = SafeAreaInsetsForDevice.bottom;
    min_w = 40;
    min_h = 40;
    self.backButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.backButton.yb_right;
    min_y = 0;
    min_w = min_view_w - min_x - 16 ;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.titleLabel.yb_centerY = self.backButton.yb_centerY;
    
    min_h = 64;
    min_x = 0;
    min_y = (min_view_h - min_h) / 2;
    min_w = min_view_w;
    self.middleToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_h = 64;
    min_w = min_h;
    min_x = (self.middleToolView.yb_width - min_w) / 2;
    min_y = 0;
    self.playOrPauseButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_h = 40;
    min_w = min_h;
    min_x = self.playOrPauseButton.yb_left - min_w - 50;
    min_y = (self.middleToolView.yb_height - min_h) / 2;
    self.previousButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.playOrPauseButton.yb_right + 50;
    self.nextButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_h = SafeAreaInsetsForDevice.bottom + 60;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = SafeAreaInsetsForDevice.left + min_margin;
    min_y = 0;
    min_w = min_view_w - min_x * 2;
    min_h = 20;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.slider.yb_left + min_margin;
    min_h = 18;
    CGSize size = [self.currentTimeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, min_h) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0]} context:nil].size;
    min_w = size.width + 8;
    min_y = (self.bottomToolView.yb_height - min_h) / 2;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    size = [self.totalTimeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, min_h) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0]} context:nil].size;
    min_w = size.width + 8;
    min_x = self.currentTimeLabel.yb_right;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.yb_centerY = self.currentTimeLabel.yb_centerY;
    
    min_w = 68;
    min_h = 24;
    min_x = self.slider.yb_right - min_margin - min_w;
    self.chapterSelectionButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.chapterSelectionButton.yb_centerY = self.totalTimeLabel.yb_centerY;
    
    if (self.chapterSelectionButton.isHidden) {
        min_x = self.slider.yb_right - min_margin - min_w;
    } else {
        min_x = self.slider.yb_right - min_w * 2 - min_margin * 2;
    }
    self.rateButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.rateButton.yb_centerY = self.totalTimeLabel.yb_centerY;
    
    
    min_x = self.backButton.yb_left;
    min_y = 0;
    min_w = 44;
    min_h = 44;
    self.lockerButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.lockerButton.yb_centerY = self.yb_centerY;
    
    if (!self.isShow) {
        self.topToolView.yb_y = -self.topToolView.yb_height;
        self.middleToolView.alpha = 0;
        self.bottomToolView.yb_y = self.yb_height;
    } else {
        if (self.player.isLockedScreen) {
            self.topToolView.yb_y = -self.topToolView.yb_height;
            self.middleToolView.alpha = 0;
            self.bottomToolView.yb_y = self.yb_height;
        } else {
            self.topToolView.yb_y = 0;
            self.middleToolView.alpha = 1.0;
            self.bottomToolView.yb_y = self.yb_height - self.bottomToolView.yb_height;
        }
    }

    min_x = min_view_w;
    min_y = 0;
    min_w = min_view_w;
    min_h = min_view_h;
    if (self.isSideRateSelectionViewShowing) {
        min_x = 0;
    }
    self.sideRateSelectionView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = min_view_w;
    if (self.isSideChapterSelectionViewShowing) {
        min_x = 0;
    }
    self.sideChapterSelectionView.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

- (void)makeSubviewsAction {
    [self.backButton addTarget:self action:@selector(backButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseButton addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.previousButton addTarget:self action:@selector(previousButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(nextButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rateButton addTarget:self action:@selector(rateButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.chapterSelectionButton addTarget:self action:@selector(chapterSelectionButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockerButton addTarget:self action:@selector(lockButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layOutControllerViews {
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - YBPlayerSliderViewDelegate

- (void)sliderTouchBegan:(float)value {
    self.slider.dragging = YES;
}

- (void)sliderTouchEnded:(float)value {
    if (self.player.totalTime > 0) {
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.dragging = NO;
            }
        }];
        if (self.seekAfterPlay) {
            [self.player.currentPlayerManager play];
        }
    } else {
        self.slider.dragging = NO;
    }
    if (self.sliderValueChanged) self.sliderValueChanged(value);
}

- (void)sliderValueChanged:(float)value {
    if (self.player.totalTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.dragging = YES;
    NSString *currentTimeString = [YBPlayerControlViewUtilities convertTimeSecond:self.player.totalTime*value];
    self.currentTimeLabel.text = currentTimeString;
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForwarding);
}

- (void)sliderTapped:(float)value {
    if (self.player.totalTime > 0) {
        self.slider.dragging = YES;
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.dragging = NO;
                [self.player.currentPlayerManager play];
            }
        }];
    } else {
        self.slider.dragging = NO;
        self.slider.value = 0;
    }
}

#pragma mark - Public

/// 重置ControlView
- (void)resetControlView {
    
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"/00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseButton.selected  = YES;
    self.titleLabel.text             = @"";
    self.topToolView.alpha           = 1;
    self.middleToolView.alpha        = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = NO;
    self.isSideRateSelectionViewShowing = NO;
    self.isSideChapterSelectionViewShowing = NO;
}

- (void)showControlView {
    self.lockerButton.alpha          = 1;
    self.isShow                      = YES;
    if (self.player.isLockedScreen) {
        self.topToolView.yb_y        = -self.topToolView.yb_height;
        self.bottomToolView.yb_y     = self.yb_height;
        self.middleToolView.alpha    = 0.0;
    } else {
        self.topToolView.yb_y        = 0;
        self.middleToolView.alpha    = 1.0;
        self.bottomToolView.yb_y     = self.yb_height - self.bottomToolView.yb_height;
    }
    self.lockerButton.yb_left        = YBIsNotchedScreen ? 50: 18;
    self.player.statusBarHidden      = NO;
    if (self.player.isLockedScreen) {
        self.topToolView.alpha       = 0;
        self.bottomToolView.alpha    = 0;
        self.middleToolView.alpha    = 0;
    } else {
        self.topToolView.alpha       = 1;
        self.middleToolView.alpha    = 1;
        self.bottomToolView.alpha    = 1;
    }
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.yb_y            = -self.topToolView.yb_height;
    self.bottomToolView.yb_y         = self.yb_height;
    self.lockerButton.yb_left        = YBIsNotchedScreen ? -82: -47;
    self.player.statusBarHidden      = YES;
    self.topToolView.alpha           = 0.0;
    self.middleToolView.alpha        = 0.0;
    self.bottomToolView.alpha        = 0.0;
    self.lockerButton.alpha          = 0;
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(YBPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    if (self.player.isLockedScreen && type != YBPlayerGestureTypeSingleTap) { // 锁定屏幕方向后只相应tap手势
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer didPlayFirstAsset:(BOOL)didPlayFirstAsset didPlayLastAsset:(BOOL)didPlayLastAsset assetURLs:(NSArray<NSURL *> *)assetURLs {
    /// 多个资源地址
    if ([assetURLs isKindOfClass:[NSArray class]] && assetURLs.count > 1) {
        self.chapterSelectionButton.hidden  = NO;
        if (didPlayFirstAsset) {
            self.previousButton.hidden      = YES;
            self.nextButton.hidden          = NO;
        }
        if (didPlayLastAsset) {
            self.previousButton.hidden      = NO;
            self.nextButton.hidden          = YES;
        }
    } else {
        self.chapterSelectionButton.hidden  = YES;
        self.previousButton.hidden          = YES;
        self.nextButton.hidden              = YES;
    }
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
    self.lockerButton.hidden = self.player.orientationObserver.fullScreenMode == YBFullScreenModePortrait;
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!self.slider.isDragging) {
        NSString *currentTimeString = [YBPlayerControlViewUtilities convertTimeSecond:currentTime];
        self.currentTimeLabel.text = currentTimeString;
        NSString *totalTimeString = [NSString stringWithFormat:@"/%@", [YBPlayerControlViewUtilities convertTimeSecond:totalTime]];
        self.totalTimeLabel.text = totalTimeString;
        self.slider.value = videoPlayer.progress;
    }
}

- (void)videoPlayer:(YBPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    self.slider.bufferValue = videoPlayer.bufferProgress;
}

- (void)showTitle:(NSString *)title fullScreenMode:(YBFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
    self.lockerButton.hidden = fullScreenMode == YBFullScreenModePortrait;
}

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
    self.currentTimeLabel.text = timeString;
    self.slider.dragging = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

/// 滑杆结束滑动
- (void)sliderChangeEnded {
    self.slider.dragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderButton.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - action

- (void)backButtonClickAction:(UIButton *)sender {
    self.lockerButton.selected = NO;
    self.player.lockedScreen = NO;
    self.lockerButton.selected = NO;
    if (self.player.orientationObserver.supportInterfaceOrientation & YBInterfaceOrientationMaskPortrait) {
        [self.player enterFullScreen:NO animated:YES];
    }
    if (self.backButtonClickCallback) {
        self.backButtonClickCallback();
    }
}

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

- (void)previousButtonClickAction:(UIButton *)sender {
    [self.player playThePrevious];
}

- (void)nextButtonClickAction:(UIButton *)sender {
    [self.player playTheNext];
}

- (void)rateButtonClickAction:(UIButton *)sender {
    
    if (self.shouldShowSideRateSelectionView) {
        self.originalTypes = self.player.disableGestureTypes;
        /// 隐藏控制层
        [UIView animateWithDuration:0.25 animations:^{
            [self hideControlView];
            self.sideRateSelectionView.yb_left = 0;
        } completion:^(BOOL finished) {
            self.isSideRateSelectionViewShowing = YES;
            self.player.disableGestureTypes = YBPlayerDisableGestureTypesAll;
        }];
    }
}

- (void)chapterSelectionButtonClickAction:(UIButton *)sender {
    
    if (self.shouldShowSideChapterSelectionView) {
        self.originalTypes = self.player.disableGestureTypes;
        /// 隐藏控制层
        [UIView animateWithDuration:0.25 animations:^{
            [self hideControlView];
            self.sideChapterSelectionView.yb_left = 0;
        } completion:^(BOOL finished) {
            self.isSideChapterSelectionViewShowing = YES;
            self.player.disableGestureTypes = YBPlayerDisableGestureTypesAll;
        }];
    }
}

/// 根据当前播放状态取反
- (void)playOrPause {
    self.playOrPauseButton.selected = !self.playOrPauseButton.isSelected;
    self.playOrPauseButton.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
}

- (void)playButtonSelection:(BOOL)selected {
    self.playOrPauseButton.selected = selected;
}

- (void)lockButtonClickAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.player.lockedScreen = sender.selected;
}

- (void)dismissSideRateSelectionView {
    if (self.shouldShowSideRateSelectionView && self.isSideRateSelectionViewShowing) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sideRateSelectionView.yb_left = self.yb_width;
        } completion:^(BOOL finished) {
            self.isSideRateSelectionViewShowing = NO;
            self.player.disableGestureTypes = self.originalTypes;
        }];
    }
}


- (void)dismissSideChapterSelectionView {
    if (self.shouldShowSideChapterSelectionView && self.isSideChapterSelectionViewShowing) {
        [UIView animateWithDuration:0.25 animations:^{
            self.sideChapterSelectionView.yb_left = self.yb_width;
        } completion:^(BOOL finished) {
            self.isSideChapterSelectionViewShowing = NO;
            self.player.disableGestureTypes = self.originalTypes;
        }];
    }
}

#pragma mark - getter

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        UIImage *image = YBUIImageMake(@"YBPlayer_top_tool_shadow");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:YBUIImageMake(@"YBPlayer_back_22x22") forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}


- (UIView *)middleToolView {
    if (!_middleToolView) {
        _middleToolView = [[UIView alloc] init];
        _middleToolView.backgroundColor = [UIColor clearColor];
    }
    return _middleToolView;
}

- (UIButton *)playOrPauseButton {
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton setImage:YBUIImageMake(@"YBPlayer_play_64x64") forState:UIControlStateNormal];
        [_playOrPauseButton setImage:YBUIImageMake(@"YBPlayer_pause_64x64") forState:UIControlStateSelected];
    }
    return _playOrPauseButton;
}

- (UIButton *)previousButton {
    if (!_previousButton) {
        _previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previousButton setImage:YBUIImageMake(@"YBPlayer_previous_normal_40x40") forState:UIControlStateNormal];
    }
    return _previousButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:YBUIImageMake(@"YBPlayer_next_normal_40x40") forState:UIControlStateNormal];
    }
    return _nextButton;
}


- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        UIImage *image = YBUIImageMake(@"YBPlayer_bottom_tool_shadow");
        _bottomToolView.layer.contents = (id)image.CGImage;
    }
    return _bottomToolView;
}


- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _currentTimeLabel;
}

- (YBPlayerSliderView *)slider {
    if (!_slider) {
        _slider = [[YBPlayerSliderView alloc] init];
        _slider.delegate = self;
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _slider.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        [_slider setThumbImage:YBUIImageMake(@"YBPlayer_slider") forState:UIControlStateNormal];
        _slider.sliderBarHeight = 2;
    }
    return _slider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _totalTimeLabel;
}


- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_rateButton setTitle:@"倍速" forState:UIControlStateNormal];
    }
    return _rateButton;
}

- (UIButton *)chapterSelectionButton {
    if (!_chapterSelectionButton) {
        _chapterSelectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chapterSelectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_chapterSelectionButton setTitle:@"选择章节" forState:UIControlStateNormal];
    }
    return _chapterSelectionButton;
}

- (UIButton *)lockerButton {
    if (!_lockerButton) {
        _lockerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockerButton setImage:YBUIImageMake(@"YBPlayer_unlocked_44x44") forState:UIControlStateNormal];
        [_lockerButton setImage:YBUIImageMake(@"YBPlayer_locked_44x44") forState:UIControlStateSelected];
    }
    return _lockerButton;
}

- (YBPlayerLandscapeSideView *)sideChapterSelectionView {
    if (!_sideChapterSelectionView) {
        _sideChapterSelectionView = [[YBPlayerLandscapeSideView alloc] initWithFrame:CGRectZero];
        _sideChapterSelectionView.rowHeight = 65.f;
        @weakify(self);
        _sideChapterSelectionView.blankAreaTappdHandler = ^(UIView * _Nonnull tappedView) {
            @strongify(self);
            [self dismissSideChapterSelectionView];
        };
        _sideChapterSelectionView.backgroundColor = [UIColor clearColor];
    }
    return _sideChapterSelectionView;
}

- (YBPlayerLandscapeSideView *)sideRateSelectionView {
    if (!_sideRateSelectionView) {
        _sideRateSelectionView = [[YBPlayerLandscapeSideView alloc] initWithFrame:CGRectZero];
        _sideRateSelectionView.rowHeight = 60.f;
        @weakify(self);
        _sideRateSelectionView.blankAreaTappdHandler = ^(UIView * _Nonnull tappedView) {
            @strongify(self);
            [self dismissSideRateSelectionView];
        };
        _sideRateSelectionView.backgroundColor = [UIColor clearColor];
    }
    return _sideRateSelectionView;
}

@end
