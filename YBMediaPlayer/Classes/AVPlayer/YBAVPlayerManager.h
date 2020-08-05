//
//  YBAVPlayerManager.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if __has_include(<YBMediaPlayer/YBPlayerMediaPlayback.h>)
#import <YBMediaPlayer/YBPlayerMediaPlayback.h>
#else
#import "YBPlayerMediaPlayback.h"
#endif

@interface YBAVPlayerManager : NSObject <YBPlayerMediaPlayback>

@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;
/// 视频请求头
@property (nonatomic, strong) NSDictionary *requestHeader;

@end
