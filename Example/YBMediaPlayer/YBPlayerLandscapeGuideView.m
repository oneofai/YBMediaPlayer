//
//  YBPlayerLandscapeGuideView.m
//  YBMediaPlayer_Example
//
//  Created by Sun on 2020/2/25.
//  Copyright © 2020 QingClass. All rights reserved.
//

#import "YBPlayerLandscapeGuideView.h"
#import <Masonry/Masonry.h>

@interface YBPlayerLandscapeGuideView ()

@property (nonatomic, strong) UIImageView *guideImageView;
@property (nonatomic, strong) UIButton    *confirmButton;

@end


@implementation YBPlayerLandscapeGuideView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    self.backgroundColor = [UIColor clearColor];
    
    _guideImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yb_guide_598x245"]];
    [self addSubview:_guideImageView];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"知道了" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.confirmButton.layer.cornerRadius = 22;
    self.confirmButton.layer.masksToBounds = YES;
    self.confirmButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.confirmButton.layer.borderWidth = 1;
    
    [self addSubview:self.confirmButton];
    
    [self setupConstraints];
}


- (void)confirmButtonAction:(UIButton *)sender {
    if (self.confirmButtonHandler) {
        self.confirmButtonHandler();
    }
}

- (void)setupConstraints {
    
    [self.guideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(120));
        make.height.equalTo(@(44));
        make.bottom.offset(-50);
    }];
}


@end
