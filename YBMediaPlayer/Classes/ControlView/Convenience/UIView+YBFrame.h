//
//  UIView+YBFrame.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (YBFrame)

@property (nonatomic) CGFloat yb_x;
@property (nonatomic) CGFloat yb_y;
@property (nonatomic) CGFloat yb_width;
@property (nonatomic) CGFloat yb_height;

@property (nonatomic) CGFloat yb_top;
@property (nonatomic) CGFloat yb_bottom;
@property (nonatomic) CGFloat yb_left;
@property (nonatomic) CGFloat yb_right;

@property (nonatomic) CGFloat yb_centerX;
@property (nonatomic) CGFloat yb_centerY;

@property (nonatomic) CGPoint yb_origin;
@property (nonatomic) CGSize  yb_size;

@end

NS_ASSUME_NONNULL_END
