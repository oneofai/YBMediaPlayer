//
//  YBPlayerFloatingView.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBPlayerFloatingView : UIView

/// The parent View
@property(nonatomic, weak) UIView *parentView;

/// Safe margins, mainly for those with Navbar and tabbar
@property(nonatomic, assign) UIEdgeInsets safeInsets;

@end

NS_ASSUME_NONNULL_END
