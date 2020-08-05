//
//  YBPlayerSpeedLoadingView.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBPlayerLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBPlayerSpeedLoadingView : UIView

@property (nonatomic, strong) YBPlayerLoadingView *loadingView;

@property (nonatomic, strong) UILabel *speedTextLabel;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
