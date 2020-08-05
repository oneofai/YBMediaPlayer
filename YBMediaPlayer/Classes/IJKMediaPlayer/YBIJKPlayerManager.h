//
//  YBIJKPlayerManager.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import <Foundation/Foundation.h>
#if __has_include(<YBMediaPlayer/YBPlayerMediaPlayback.h>)
#import <YBMediaPlayer/YBPlayerMediaPlayback.h>
#else
#import "YBPlayerMediaPlayback.h"
#endif

#if __has_include(<IJKMediaFramework/IJKMediaFramework.h>)
#import <IJKMediaFramework/IJKMediaFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBIJKPlayerManager : NSObject <YBPlayerMediaPlayback>

@property (nonatomic, strong, readonly) IJKFFMoviePlayerController *player;

@property (nonatomic, strong, readonly) IJKFFOptions *options;

@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;

@end

NS_ASSUME_NONNULL_END

#endif
