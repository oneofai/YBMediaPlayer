//
//  YBPlayerGestureControl.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//


#import "YBPlayerGestureControl.h"

@interface YBPlayerGestureControl ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGR;
@property (nonatomic) YBPanDirection panDirection;
@property (nonatomic) YBPanLocation panLocation;
@property (nonatomic) YBPanMovingDirection panMovingDirection;
@property (nonatomic, weak) UIView *targetView;

@end

@implementation YBPlayerGestureControl

- (void)addGestureToView:(UIView *)view {
    self.targetView = view;
    self.targetView.multipleTouchEnabled = YES;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.singleTap  requireGestureRecognizerToFail:self.panGR];
    [self.targetView addGestureRecognizer:self.singleTap];
    [self.targetView addGestureRecognizer:self.doubleTap];
    [self.targetView addGestureRecognizer:self.panGR];
    [self.targetView addGestureRecognizer:self.pinchGR];
    [self.targetView addGestureRecognizer:self.longPress];
}

- (void)removeGestureToView:(UIView *)view {
    [view removeGestureRecognizer:self.singleTap];
    [view removeGestureRecognizer:self.doubleTap];
    [view removeGestureRecognizer:self.panGR];
    [view removeGestureRecognizer:self.pinchGR];
    [view removeGestureRecognizer:self.longPress];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer == self.panGR) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.targetView];
        CGFloat x = fabs(translation.x);
        CGFloat y = fabs(translation.y);
        if (x < y && self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionVertical) { /// up and down moving direction.
            return NO;
        } else if (x > y && self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionHorizontal) { /// left and right moving direction.
            return NO;
        }
    }
    
    if (gestureRecognizer == self.longPress) {
        return !(self.disableTypes & YBPlayerDisableGestureTypesLongPress);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    YBPlayerGestureType type = YBPlayerGestureTypeUnknown;
    if (gestureRecognizer == self.singleTap) type = YBPlayerGestureTypeSingleTap;
    else if (gestureRecognizer == self.doubleTap) type = YBPlayerGestureTypeDoubleTap;
    else if (gestureRecognizer == self.panGR) type = YBPlayerGestureTypePan;
    else if (gestureRecognizer == self.pinchGR) type = YBPlayerGestureTypePinch;
    else if (gestureRecognizer == self.longPress) type = YBPlayerGestureTypeLongPress;
    
    CGPoint locationPoint = [touch locationInView:touch.view];
    if (locationPoint.x > _targetView.bounds.size.width / 2) {
        self.panLocation = YBPanLocationRight;
    } else {
        self.panLocation = YBPanLocationLeft;
    }
    
    switch (type) {
        case YBPlayerGestureTypeUnknown: break;
        case YBPlayerGestureTypePan: {
            if (self.disableTypes & YBPlayerDisableGestureTypesPan) {
                return NO;
            }
        }
            break;
        case YBPlayerGestureTypePinch: {
            if (self.disableTypes & YBPlayerDisableGestureTypesPinch) {
                return NO;
            }
        }
            break;
        case YBPlayerGestureTypeDoubleTap: {
            if (self.disableTypes & YBPlayerDisableGestureTypesDoubleTap) {
                return NO;
            }
        }
            break;
        case YBPlayerGestureTypeSingleTap: {
            if (self.disableTypes & YBPlayerDisableGestureTypesSingleTap) {
                return NO;
            }
        }
            break;
        case YBPlayerGestureTypeLongPress: {
            if (self.disableTypes & YBPlayerDisableGestureTypesLongPress) {
                return NO;
            }
        }
            break;
    }
    
    if (self.triggerCondition) return self.triggerCondition(self, type, gestureRecognizer, touch);
    return YES;
}

// Whether to support multi-trigger, return YES, you can trigger a method with multiple gestures, return NO is mutually exclusive
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer != self.singleTap &&
        otherGestureRecognizer != self.doubleTap &&
        otherGestureRecognizer != self.panGR &&
        otherGestureRecognizer != self.pinchGR) return NO;
    
    if (gestureRecognizer == self.panGR) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.targetView];
        CGFloat x = fabs(translation.x);
        CGFloat y = fabs(translation.y);
        if (x < y && self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionVertical) {
            return YES;
        } else if (x > y && self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionHorizontal) {
            return YES;
        }
    }
    
    if (gestureRecognizer == self.longPress) {
        return !(self.disableTypes & YBPlayerDisableGestureTypesLongPress);
    }
    
    if (gestureRecognizer.numberOfTouches >= 2) {
        return NO;
    }
    return YES;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap){
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.delegate = self;
        _singleTap.delaysTouchesBegan = YES;
        _singleTap.delaysTouchesEnded = YES;
        _singleTap.numberOfTouchesRequired = 1;  
        _singleTap.numberOfTapsRequired = 1;
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.delegate = self;
        _doubleTap.delaysTouchesBegan = YES;
        _singleTap.delaysTouchesEnded = YES;
        _doubleTap.numberOfTouchesRequired = 1; 
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)panGR {
    if (!_panGR) {
        _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGR.delegate = self;
        _panGR.delaysTouchesBegan = YES;
        _panGR.delaysTouchesEnded = YES;
        _panGR.maximumNumberOfTouches = 1;
        _panGR.cancelsTouchesInView = YES;
    }
    return _panGR;
}
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPress.delegate = self;
        _longPress.delaysTouchesBegan = YES;
        _longPress.delaysTouchesEnded = YES;
        _longPress.numberOfTapsRequired = 1;
        // TODO: 未处理允许滚动
        _longPress.allowableMovement = NO;
        _longPress.cancelsTouchesInView = YES;
    }
    return _longPress;
}

- (UIPinchGestureRecognizer *)pinchGR {
    if (!_pinchGR) {
        _pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        _pinchGR.delegate = self;
        _pinchGR.delaysTouchesBegan = YES;
    }
    return _pinchGR;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if (self.disableTypes & YBPlayerDisableGestureTypesSingleTap) {
        return;
    }
    if (self.singleTapped) self.singleTapped(self);
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (self.disableTypes & YBPlayerDisableGestureTypesDoubleTap) {
        return;
    }
    if (self.doubleTapped) self.doubleTapped(self);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    if (self.disableTypes & YBPlayerDisableGestureTypesPan) {
        return;
    }
    
    CGPoint translate = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.panMovingDirection = YBPanMovingDirectionUnkown;
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            if (x > y) {
                if (self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionHorizontal) {
                    return;
                }
                self.panDirection = YBPanDirectionH;
            } else if (x < y) {
                if (self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionVertical) {
                    return;
                }
                self.panDirection = YBPanDirectionV;
            } else {
                self.panDirection = YBPanDirectionUnknown;
                return;
            }
            if (self.beganPan) self.beganPan(self, self.panDirection, self.panLocation);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            switch (_panDirection) {
                case YBPanDirectionH: {
                    if (self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionHorizontal) {
                        return;
                    }
                    if (translate.x > 0) {
                        self.panMovingDirection = YBPanMovingDirectionRight;
                    } else if (translate.y < 0) {
                        self.panMovingDirection = YBPanMovingDirectionLeft;
                    }
                }
                    break;
                case YBPanDirectionV: {
                    if (self.disablePanMovingDirection & YBPlayerDisablePanMovingDirectionVertical) {
                        return;
                    }
                    if (translate.y > 0) {
                        self.panMovingDirection = YBPanMovingDirectionBottom;
                    } else {
                        self.panMovingDirection = YBPanMovingDirectionTop;
                    }
                }
                    break;
                case YBPanDirectionUnknown:
                    return;
            }
            if (self.changedPan) self.changedPan(self, self.panDirection, self.panLocation, velocity);
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (self.endedPan) self.endedPan(self, self.panDirection, self.panLocation);
        }
            break;
        default:
            break;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch {
    if (self.disableTypes & YBPlayerDisableGestureTypesPinch) {
        return;
    }
    switch (pinch.state) {
        case UIGestureRecognizerStateEnded: {
            if (self.pinched) self.pinched(self, pinch.scale);
        }
            break;
        default:
            break;
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (self.disableTypes & YBPlayerDisableGestureTypesLongPress) {
        return;
    }
    
    if (self.longPressed) {
        self.longPressed(self);
    }
}

@end
