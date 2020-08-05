//
//  YBPlayerLandscapeSideView.m
//  YBMediaPlayer
//
//  Created by Sun on 2019/12/27.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerLandscapeSideView.h"
#import "YBPlayerControlViewUtilities.h"
#import "UIImageView+YBWebCache.h"
#import "UIView+YBFrame.h"
#if __has_include(<YBMediaPlayer/YBMediaPlayer.h>)
#import <YBMediaPlayer/YBMediaPlayer.h>
#else
#import "YBMediaPlayer.h"
#endif

//#pragma mark - 倍速选择
//@interface YBPlayerLandscapeRateViewCell : UITableViewCell
//
//@property (nonatomic, strong) YBPlayerRateModel *rateModel;
//
//@property (nonatomic, strong) UILabel *rateTitleLabel;
//
//@end
//
//@implementation YBPlayerLandscapeRateViewCell
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self setupSubviews];
//    }
//    return self;
//}
//
//- (void)setupSubviews {
//
//    _rateTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _rateTitleLabel.font = [UIFont systemFontOfSize:16];
//    _rateTitleLabel.textColor = [UIColor whiteColor];
//    _rateTitleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.contentView addSubview:_rateTitleLabel];
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    CGFloat min_x = 0;
//    CGFloat min_y = 0;
//    CGFloat min_view_w = self.bounds.size.width;
//    CGFloat min_view_h = self.bounds.size.height;
//
//    _rateTitleLabel.frame = CGRectMake(min_x, min_y, min_view_w, min_view_h);
//}
//
//- (void)setRateEntity:(YBPlayerRateModel *)rateEntity {
//    _rateEntity = rateEntity;
//    _rateTitleLabel.text = rateEntity.rateDesc ?: @"不可用";
//    if (rateEntity.isSelected) {
//        _rateTitleLabel.textColor = [UIColor colorWithRed:242/255.0 green:114/255.0 blue:114/255.0 alpha:1.0];
//    } else {
//        _rateTitleLabel.textColor = [UIColor whiteColor];
//    }
//}
//
//@end
//
//
//#pragma mark - 章节选择
//@interface YBPlayerLandscapeChapterSelectionCell : UITableViewCell
//
//#warning TODO
//@property (nonatomic, strong) YBPlayerRateModel *chapterEntity;
//
//@property (nonatomic, strong) UIImageView *coverImageView;
//@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *subtitleLabel;
//
//@end
//
//@implementation YBPlayerLandscapeChapterSelectionCell
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self setupSubviews];
//    }
//    return self;
//}
//
//- (void)setupSubviews {
//
//    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    _coverImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//    [self.contentView addSubview:_coverImageView];
//
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _titleLabel.font = [UIFont systemFontOfSize:14];
//    _titleLabel.textColor = [UIColor whiteColor];
//    _titleLabel.textAlignment = NSTextAlignmentLeft;
//    [self.contentView addSubview:_titleLabel];
//
//    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _subtitleLabel.font = [UIFont systemFontOfSize:12];
//    _subtitleLabel.textColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255 alpha:1.0];
//    _subtitleLabel.textAlignment = NSTextAlignmentLeft;
//    [self.contentView addSubview:_subtitleLabel];
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//    CGFloat min_x = 0;
//    CGFloat min_y = 0;
//    CGFloat min_w = 0;
//    CGFloat min_h = 0;
//    CGFloat min_view_w = self.contentView.bounds.size.width;
//    CGFloat min_view_h = self.contentView.bounds.size.height;
//
//    CGFloat min_x = 32;
//    CGFloat min_h = 45;
//    CGFloat min_y = (min_view_h - min_h) * 0.5;
//    CGFloat min_w = 80;
//    _coverImageView.frame = CGRectMake(min_x, min_y, min_view_w, min_view_h);
//
//    CGFloat min_x = self.coverImageView.yb_right + 10;
//    CGFloat min_h = 20;
//    CGFloat min_y = self.contentView.yb_centerY - min_h - 2;
//    CGFloat min_w = min_view_w - min_x - SafeAreaInsetsForDevice.right - 32;
//    _titleLabel.frame = CGRectMake(min_x, min_y, min_view_w, min_view_h);
//
//    CGFloat min_x = self.coverImageView.yb_right + 10;
//    CGFloat min_h = 20;
//    CGFloat min_y = self.contentView.yb_centerY + 2;
//    CGFloat min_w = min_view_w - min_x - SafeAreaInsetsForDevice.right - 32;
//    _subtitleLabel.frame = CGRectMake(min_x, min_y, min_view_w, min_view_h);
//}
//
//- (void)setChapterEntity:(YBPlayerRateModel *)chapterEntity {
//    _chapterEntity = chapterEntity;
//    // [_coverImageView setImageWithURLString:chapterEntity placeholder:nil];
//    if (rateEntity.isSecleted) {
//        _titleLabel.textColor = [UIColor colorWithRed:242/255.0 green:114/255.0 blue:114/255.0 alpha:1.0];
//    } else {
//        _titleLabel.textColor = [UIColor whiteColor];
//    }
//}
//
//@end

@interface YBPlayerLandscapeSideView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *tapGestureView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation YBPlayerLandscapeSideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


- (void)setupSubviews {
    
    self.rowHeight = 44;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
    _tableView.scrollEnabled = NO;
    [self addSubview:_tableView];
    
    _tapGestureView = [[UIView alloc] initWithFrame:CGRectZero];
    _tapGestureView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tapGestureView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureAction:)];
    [_tapGestureView addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    min_y = 0;
    min_w = min_view_w * 0.4;
    min_x = min_view_w - min_w;
    min_h = min_view_h;
    _tableView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_y = 0;
    min_w = min_view_w - CGRectGetWidth(_tableView.frame);
    min_x = 0;
    _tapGestureView.frame = CGRectMake(min_x, min_y, min_w, min_h);
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideView:didSelectedRow:)]) {
        [self.delegate sideView:self didSelectedRow:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideView:heightForRow:)]) {
        return [self.delegate sideView:self heightForRow:indexPath.row];
    }
    
    return self.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerHeightForSideView:)]) {
        return [self.delegate headerHeightForSideView:self];
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.delegate && [self.delegate respondsToSelector:@selector(footerHeightForSideView:)]) {
        return [self.delegate footerHeightForSideView:self];
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    return footerView;
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRowsInSideView:)]) {
        return [self.dataSource numberOfRowsInSideView:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(sideView:cellForRow:)]) {
        return [self.dataSource sideView:self cellForRow:indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    return cell;
}


- (void)handleTapGestureAction:(UITapGestureRecognizer *)tapGesture {
    if (self.blankAreaTappdHandler) {
        self.blankAreaTappdHandler(tapGesture.view);
    }
}

#pragma mark - Getter

- (NSInteger)numberOfRows {
    return [self.tableView numberOfRowsInSection:0];
}

#pragma mark - Public

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    if (!_tableView) {
        return;
    }
    
    [_tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}


- (void)reloadData {
    [self.tableView reloadData];
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

@end
