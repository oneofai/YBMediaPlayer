//
//  YBNetworkSpeedMonitor.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const YBDownloadNetworkSpeedNotificationKey;
extern NSString *const YBUploadNetworkSpeedNotificationKey;
extern NSString *const YBNetworkSpeedNotificationKey;

@interface YBNetworkSpeedMonitor : NSObject

@property (nonatomic, copy, readonly) NSString *downloadNetworkSpeed;
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;

- (void)startNetworkSpeedMonitor;
- (void)stopNetworkSpeedMonitor;

@end

NS_ASSUME_NONNULL_END
