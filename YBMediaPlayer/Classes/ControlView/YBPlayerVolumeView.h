//
//  YBPlayerVolumeView.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YBPlayerVolumeType) {
    YBPlayerVolumeTypeSonic,        // sound
    YBPlayerVolumeTypeumeBrightness // brightness
};

@interface YBPlayerVolumeView : UIView

@property (nonatomic, assign, readonly) YBPlayerVolumeType volumeType;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;

- (void)updateProgress:(CGFloat)progress volumeType:(YBPlayerVolumeType)volumeType;

/// 添加系统音量view
- (void)addSystemVolumeView;

/// 移除系统音量view
- (void)removeSystemVolumeView;

@end

NS_ASSUME_NONNULL_END
