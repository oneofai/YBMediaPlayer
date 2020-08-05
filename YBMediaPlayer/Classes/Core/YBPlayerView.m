//
//  YBPlayerView.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerView.h"
#import "YBMediaPlayer.h"

@interface YBPlayerView ()

@property (nonatomic, weak) UIView *fitView;
@end

@implementation YBPlayerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Determine whether you can receive touch events
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    // Determine if the touch point is out of reach
    if (![self pointInside:point withEvent:event]) return nil;
    NSInteger count = self.subviews.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];
        CGPoint childPoint = [self convertPoint:point toView:childView];
        UIView *fitView = [childView hitTest:childPoint withEvent:event];
        if (fitView) {
            return fitView;
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
