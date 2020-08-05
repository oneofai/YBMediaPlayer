//
//  YBPlayerLandscapeGuideView.h
//  YBMediaPlayer_Example
//
//  Created by Sun on 2020/2/25.
//  Copyright © 2020 QingClass. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBPlayerLandscapeGuideView : UIView

@property (nonatomic, copy) void(^confirmButtonHandler)(void);

@end

NS_ASSUME_NONNULL_END
