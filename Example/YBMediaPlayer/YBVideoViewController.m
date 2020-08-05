//
//  YBVideoViewController.m
//  AnyDemos
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBVideoViewController.h"
#import <YBMediaPlayer/YBMediaPlayer.h>
#import <YBMediaPlayer/YBIJKPlayerManager.h>

#import <YBMediaPlayer/YBPlayerControlView.h>
#import <YBMediaPlayer/UIImageView+YBWebCache.h>
#import <YBMediaPlayer/YBPlayerControlViewUtilities.h>

#import "YBPlayerLandscapeSideRateCell.h"
#import "YBPlayerLandscapeGuideView.h"

#define kYBVideoGuideKey @"kYBVideoGuideKey"

static NSString * const kCoverImageURLString = @"https://tva1.sinaimg.cn/large/006tNbRwgy1ga99y60ajlj30m80dwagz.jpg";

@interface YBVideoViewController () <UITableViewDelegate, UITableViewDataSource, YBPlayerLandscapeSideViewDelegate, YBPlayerLandscapeSideViewDataSource>

@property (nonatomic, strong) NSArray<NSURL *> *urls;

@property (nonatomic, strong) YBPlayerController *player;
@property (nonatomic, strong) YBPlayerControlView *controlView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, assign) BOOL beforeIsPlaying;

@end

@implementation YBVideoViewController

- (instancetype)initWithURLs:(NSArray<NSURL *> *)urls {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.urls = urls;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.coverView];
    [self.containerView addSubview:self.playButton];
    [self.view addSubview:self.tableView];

    YBIJKPlayerManager *playerManager = [[YBIJKPlayerManager alloc] init];
    
        /// 播放器相关
    self.player = [YBPlayerController playerWithPlayerManager:playerManager containerView:self.containerView];
    [self.controlView.landscapeControlView.sideRateSelectionView registerClass:[YBPlayerLandscapeSideRateCell class] forCellReuseIdentifier:NSStringFromClass(YBPlayerLandscapeSideRateCell.class)];
    self.player.controlView = self.controlView;
    self.player.shouldAutoPlay = NO;
    self.player.forceDeviceOrientation = YES;
    /// 设置退到后台继续播放
    self.player.pauseWhenAppResignActive = YES;
    
    @weakify(self)
    self.player.orientationWillChange = ^(YBPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    self.player.orientationDidChanged = ^(YBPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        
        if (isFullScreen) {
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            BOOL hasShown = [defaults boolForKey:kYBVideoGuideKey];


            YBPlayerLandscapeGuideView *guideView = [[YBPlayerLandscapeGuideView alloc] initWithFrame:self.view.frame];
            [player.controlView addSubview:guideView];
            @weakify(guideView);
            guideView.confirmButtonHandler = ^{
                @strongify(guideView);
                [self dismissGuideView:guideView];
            };
//
            [self.controlView.landscapeControlView hideControlView];
            self.beforeIsPlaying = [player.currentPlayerManager isPlaying];
            if (self.beforeIsPlaying) {
                [player.currentPlayerManager pause];
            }

//            strongControlView.guideViewDidDismiss = ^{
//                if (isPlaying) {
//                    [player.currentPlayerManager play];
//                }

//                [defaults setBool:YES forKey:kYBVideoGuideKey];
//                [defaults synchronize];
//            };
        }
    };
    /// 播放完成
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager replay];
        [self.player playTheNext];
        if (!self.player.isLastAssetURL) {
            NSString *title = [NSString stringWithFormat:@"视频标题%zd", self.player.currentPlayIndex];
            [self.controlView showTitle:title coverURLString:kCoverImageURLString fullScreenMode:YBFullScreenModeLandscape];
        } else {
            [self.player stop];
        }
    };
    
    self.player.assetURLs = self.urls;
}

- (void)dismissGuideView:(YBPlayerLandscapeGuideView *)guideView {
    [guideView removeFromSuperview];
    guideView = nil;
    if (self.beforeIsPlaying) {
        [self.player.currentPlayerManager play];
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.containerView.frame = CGRectMake(0, self.view.safeAreaInsets.top, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9 / 16);
    } else {
        self.containerView.frame = CGRectMake(0, self.topLayoutGuide.length, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9 / 16);
    }
    self.coverView.frame = self.containerView.bounds;
    self.playButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 64) * 0.5, (CGRectGetHeight(self.containerView.frame) - 64) * 0.5, 64, 64);
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.containerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.containerView.frame));
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.player.isFullScreen) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate {
    if (!self.player.allowOrentitaionRotation) {
        return NO;
    }
    return self.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.player.isFullScreen) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}


- (void)playClick:(UIButton *)sender {
    [self.player playTheIndex:0];
    [self.controlView showTitle:@"视频标题" coverURLString:kCoverImageURLString fullScreenMode:YBFullScreenModeAutomatic];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"测试，IndexPath(%zd,%zd)", indexPath.section, indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [UIView new];
    header.backgroundColor = [UIColor brownColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

#pragma mark - YBPlayerLandscapeSideViewDelegate

- (CGFloat)headerHeightForSideView:(YBPlayerLandscapeSideView *)sideView {
    return 30;
}

- (CGFloat)footerHeightForSideView:(YBPlayerLandscapeSideView *)sideView {
    return 30;
}

#pragma mark - YBPlayerLandscapeSideViewDataSource

- (NSInteger)numberOfRowsInSideView:(YBPlayerLandscapeSideView *)sideView {
    return 5;
}

- (UITableViewCell *)sideView:(YBPlayerLandscapeSideView *)sideView cellForRow:(NSInteger)row {
    YBPlayerLandscapeSideRateCell *cell = [sideView dequeueReusableCellWithIdentifier:NSStringFromClass(YBPlayerLandscapeSideRateCell.class)];
    cell.textLabel.text = [NSString stringWithFormat:@"测试, row(%zd)", row];
    return cell;
}

#pragma mark - getter

- (YBPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [YBPlayerControlView new];
        _controlView.shouldAnimateFastForwardRewind = YES;
        _controlView.viewScene = YBPlayerControlViewSceneBusinessSchool;
        _controlView.landscapeControlView.sideRateSelectionView.delegate = self;
        _controlView.landscapeControlView.sideRateSelectionView.dataSource = self;
        _controlView.autoHiddenTimeInterval = 5;
        _controlView.autoFadeTimeInterval = 0.5;
        _controlView.dispayLoadingViewWhenPlayerPrepared = YES;
        _controlView.dispayControlViewWhenPlayerPrepared = YES;
    }
    return _controlView;
}

- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [UIImageView new];
        _coverView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        [_coverView setImageWithURLString:kCoverImageURLString placeholder:[YBPlayerControlViewUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:CGSizeMake(1, 1)]];
    }
    return _coverView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}


- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"play_64x64"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)dealloc
{
    NSLog(@"释放");
}

@end
