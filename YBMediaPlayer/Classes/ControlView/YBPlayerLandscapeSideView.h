//
//  YBPlayerLandscapeSideView.h
//  YBMediaPlayer
//
//  Created by Sun on 2019/12/27.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<YBMediaPlayer/YBPlayerController.h>)
#import <YBMediaPlayer/YBPlayerController.h>
#else
#import "YBPlayerController.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class YBPlayerLandscapeSideView;

@protocol YBPlayerLandscapeSideViewDataSource <NSObject>

@required

/// 列表个数
- (NSInteger)numberOfRowsInSideView:(YBPlayerLandscapeSideView *)sideView;

- (__kindof UITableViewCell *)sideView:(YBPlayerLandscapeSideView *)sideView cellForRow:(NSInteger)row;

@end

@protocol YBPlayerLandscapeSideViewDelegate <NSObject>

@optional

/// 选中的回调
- (void)sideView:(YBPlayerLandscapeSideView *)sideView didSelectedRow:(NSInteger)row;
/// row 高度
- (CGFloat)sideView:(YBPlayerLandscapeSideView *)sideView heightForRow:(NSInteger)row;

- (CGFloat)headerHeightForSideView:(YBPlayerLandscapeSideView *)sideView;

- (CGFloat)footerHeightForSideView:(YBPlayerLandscapeSideView *)sideView;

@end


@interface YBPlayerLandscapeSideView : UIView

@property (nonatomic, weak, nullable) id <YBPlayerLandscapeSideViewDataSource> dataSource;

@property (nonatomic, weak, nullable) id <YBPlayerLandscapeSideViewDelegate> delegate;

@property (nonatomic, copy, nullable) void(^blankAreaTappdHandler)(UIView *tappedView);

// 行高，默认44
@property (nonatomic, assign) CGFloat rowHeight;

// row 数量
@property (nonatomic, assign, readonly) NSInteger numberOfRows;

// 播放器
@property (nonatomic, weak) YBPlayerController *player;

// 重载数据
- (void)reloadData;

// 注册 cells
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

// dequeue cells
- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
