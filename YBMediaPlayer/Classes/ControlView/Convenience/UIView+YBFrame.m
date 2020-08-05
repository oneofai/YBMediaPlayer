//
//  UIView+YBFrame.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "UIView+YBFrame.h"

@implementation UIView (YBFrame)

- (CGFloat)yb_x {
    return self.frame.origin.x;
}

- (void)setYb_x:(CGFloat)yb_x {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = yb_x;
    self.frame        = newFrame;
}

- (CGFloat)yb_y {
    return self.frame.origin.y;
}

- (void)setYb_y:(CGFloat)yb_y {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = yb_y;
    self.frame        = newFrame;
}

- (CGFloat)yb_width {
    return CGRectGetWidth(self.bounds);
}

- (void)setYb_width:(CGFloat)yb_width {
    CGRect newFrame     = self.frame;
    newFrame.size.width = yb_width;
    self.frame          = newFrame;
}

- (CGFloat)yb_height {
    return CGRectGetHeight(self.bounds);
}

- (void)setYb_height:(CGFloat)yb_height {
    CGRect newFrame      = self.frame;
    newFrame.size.height = yb_height;
    self.frame           = newFrame;
}

- (CGFloat)yb_top {
    return self.frame.origin.y;
}

- (void)setYb_top:(CGFloat)yb_top {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = yb_top;
    self.frame        = newFrame;
}

- (CGFloat)yb_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setYb_bottom:(CGFloat)yb_bottom {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = yb_bottom - self.frame.size.height;
    self.frame        = newFrame;
}

- (CGFloat)yb_left {
    return self.frame.origin.x;
}

- (void)setYb_left:(CGFloat)yb_left {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = yb_left;
    self.frame        = newFrame;
}

- (CGFloat)yb_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setYb_right:(CGFloat)yb_right {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = yb_right - self.frame.size.width;
    self.frame        = newFrame;
}

- (CGFloat)yb_centerX {
    return self.center.x;
}

- (void)setYb_centerX:(CGFloat)yb_centerX {
    CGPoint newCenter = self.center;
    newCenter.x       = yb_centerX;
    self.center       = newCenter;
}

- (CGFloat)yb_centerY {
    return self.center.y;
}

- (void)setYb_centerY:(CGFloat)yb_centerY {
    CGPoint newCenter = self.center;
    newCenter.y       = yb_centerY;
    self.center       = newCenter;
}

- (CGPoint)yb_origin {
    return self.frame.origin;
}

- (void)setYb_origin:(CGPoint)yb_origin {
    CGRect newFrame = self.frame;
    newFrame.origin = yb_origin;
    self.frame      = newFrame;
}

- (CGSize)yb_size {
    return self.frame.size;
}

- (void)setYb_size:(CGSize)yb_size {
    CGRect newFrame = self.frame;
    newFrame.size   = yb_size;
    self.frame      = newFrame;
}

@end
