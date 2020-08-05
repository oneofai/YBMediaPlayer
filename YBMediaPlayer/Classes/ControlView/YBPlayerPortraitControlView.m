//
//  YBPlayerPortraitControlView.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerPortraitControlView.h"
#import "UIView+YBFrame.h"
#import "YBPlayerControlViewUtilities.h"
#if __has_include(<YBMediaPlayer/YBMediaPlayer.h>)
#import <YBMediaPlayer/YBMediaPlayer.h>
#else
#import "YBMediaPlayer.h"
#endif

@interface YBPlayerPortraitControlView () <YBPlayerSliderViewDelegate>

/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
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
/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenButton;

@property (nonatomic, assign) BOOL isShow;

@end

@implementation YBPlayerPortraitControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加子控件
        [self addSubview:self.topToolView];
        [self.topToolView addSubview:self.titleLabel];
        
        [self addSubview:self.middleToolView];
        [self.middleToolView addSubview:self.playOrPauseButton];
        [self.middleToolView addSubview:self.previousButton];
        [self.middleToolView addSubview:self.nextButton];
        
        [self addSubview:self.bottomToolView];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.fullScreenButton];
        
        // 设置子控件的响应事件
        [self makeSubviewsAction];
        
        [self resetControlView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)makeSubviewsAction {
    
    [self.playOrPauseButton addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.previousButton addTarget:self action:@selector(previousButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(nextButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.fullScreenButton addTarget:self action:@selector(fullScreenButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - action

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

- (void)previousButtonClickAction:(UIButton *)sender {
    [self.player playThePrevious];
}

- (void)nextButtonClickAction:(UIButton *)sender {
    [self.player playTheNext];
}

- (void)fullScreenButtonClickAction:(UIButton *)sender {
    [self.player enterFullScreen:YES animated:YES];
}

/// 根据当前播放状态取反
- (void)playOrPause {
    self.playOrPauseButton.selected = !self.playOrPauseButton.isSelected;
    self.playOrPauseButton.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
}

- (void)playButtonSelection:(BOOL)selected {
    self.playOrPauseButton.selected = selected;
}

#pragma mark - 添加子控件约束

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    CGFloat min_margin = 16;
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = 40;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 15;
    min_y = 5;
    min_w = min_view_w - min_x - 15;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_h = 64;
    min_x = 0;
    min_y = (min_view_h - min_h) / 2;
    min_w = min_view_w;
    self.middleToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = 64;
    min_h = min_w;
    self.playOrPauseButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playOrPauseButton.yb_centerX = self.middleToolView.yb_centerX;
    
    min_w = 40;
    min_x = self.playOrPauseButton.yb_left - min_w - 50;
    min_h = min_w;
    min_y = (self.middleToolView.yb_height - min_h) / 2;
    self.previousButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.playOrPauseButton.yb_right + 50;
    min_w = 40;
    min_h = min_w;
    min_y = (self.middleToolView.yb_height - min_h) / 2;
    self.nextButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_h = 44;
    min_x = 0;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = min_margin;
    min_h = 18;
    CGSize size = [self.currentTimeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, min_h) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0]} context:nil].size;
    min_w = size.width + 6;
    min_y = 0;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_h = 18;
    size = [self.totalTimeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, min_h) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12.0]} context:nil].size;
    min_w = size.width + 6;
    min_x = self.currentTimeLabel.yb_right;
    min_y = 0;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.yb_centerY = self.currentTimeLabel.yb_centerY;
    
    
    min_w = 22;
    min_h = min_w;
    min_x = self.bottomToolView.yb_width - min_w - min_margin;
    min_y = self.bottomToolView.yb_height - min_h - min_margin;
    self.fullScreenButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    
    min_x = min_margin;
    min_w = self.fullScreenButton.yb_left - min_x - min_margin;
    min_h = 20;
    min_y = self.fullScreenButton.yb_bottom - min_h / 2 - 2;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    if (!self.isShow) {
        self.topToolView.yb_y = -self.topToolView.yb_height;
        self.bottomToolView.yb_y = self.yb_height;
        self.middleToolView.alpha = 0;
    } else {
        self.topToolView.yb_y = 0;
        self.bottomToolView.yb_y = self.yb_height - self.bottomToolView.yb_height;
        self.middleToolView.alpha = 1;
    }
}

#pragma mark - 

/** 重置ControlView */
- (void)resetControlView {
    self.bottomToolView.alpha        = 1;
    self.middleToolView.alpha        = 1;
    self.topToolView.alpha           = 1;
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"/00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseButton.selected  = YES;
    self.titleLabel.text             = @"";
}

- (void)showControlView {
    self.topToolView.alpha           = 1;
    self.middleToolView.alpha        = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = YES;
    self.topToolView.yb_y            = 0;
    self.bottomToolView.yb_y         = self.yb_height - self.bottomToolView.yb_height;
    self.player.statusBarHidden      = NO;
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.yb_y            = -self.topToolView.yb_height;
    self.bottomToolView.yb_y         = self.yb_height;
    self.player.statusBarHidden      = NO;
    self.topToolView.alpha           = 0;
    self.middleToolView.alpha        = 0;
    self.bottomToolView.alpha        = 0;
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(YBPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    return YES;
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

- (void)videoPlayer:(YBPlayerController *)videoPlayer didPlayFirstAsset:(BOOL)didPlayFirstAsset didPlayLastAsset:(BOOL)didPlayLastAsset assetURLs:(NSArray<NSURL *> *)assetURLs {
    /// 多个资源地址
    if ([assetURLs isKindOfClass:[NSArray class]] && assetURLs.count > 1) {
        if (didPlayFirstAsset) {
            self.previousButton.hidden  = YES;
            self.nextButton.hidden      = NO;
        }
        if (didPlayLastAsset) {
            self.previousButton.hidden  = NO;
            self.nextButton.hidden      = YES;
        }
    } else {
        self.previousButton.hidden      = YES;
        self.nextButton.hidden          = YES;
    }
}

- (void)showTitle:(NSString *)title fullScreenMode:(YBFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
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

#pragma mark - getter

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        UIImage *image = YBUIImageMake(@"YBPlayer_top_tool_shadow");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
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

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:YBUIImageMake(@"YBPlayer_full_screen_22x22") forState:UIControlStateNormal];
    }
    return _fullScreenButton;
}

@end
