//
//  YBPlayerNotification.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YBPlayerBackgroundState) {
    YBPlayerBackgroundStateForeground,  // Enter the foreground from the background.
    YBPlayerBackgroundStateBackground,  // From the foreground to the background.
};

@interface YBPlayerNotification : NSObject

@property (nonatomic, readonly) YBPlayerBackgroundState backgroundState;

@property (nonatomic, copy, nullable) void(^willResignActive)(YBPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(YBPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(YBPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(YBPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(YBPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^volumeChanged)(float volume);

@property (nonatomic, copy, nullable) void(^audioInterruptionCallback)(AVAudioSessionInterruptionType interruptionType);

- (void)addNotification;

- (void)removeNotification;

@end

NS_ASSUME_NONNULL_END
