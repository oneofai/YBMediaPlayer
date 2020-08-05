//
//  YBPlayerFloatingControlView.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBPlayerControlViewUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBPlayerFloatingControlView : UIView

@property (nonatomic, copy, nullable) void(^closeButtonTappedHandler)(void);

@end

NS_ASSUME_NONNULL_END
