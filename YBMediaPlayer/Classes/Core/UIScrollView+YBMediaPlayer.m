//
//  UIScrollView+YBMediaPlayer.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "UIScrollView+YBMediaPlayer.h"
#import <objc/runtime.h>
#import "YBPlayerReachabilityManager.h"
#import "YBMediaPlayer.h"
#import "YBPlayerKVOController.h"

@interface UIScrollView ()

@property (nonatomic) CGFloat yb_lastOffsetY;
@property (nonatomic) CGFloat yb_lastOffsetX;
@property (nonatomic) YBPlayerScrollDirection yb_scrollDirection;

@end

@implementation UIScrollView (YBMediaPlayer)

#pragma mark - private method

- (void)_scrollViewDidStopScroll {
    @weakify(self)
    [self yb_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.yb_scrollViewDidStopScrollCallback) self.yb_scrollViewDidStopScrollCallback(indexPath);
    }];
}

- (void)_scrollViewBeginDragging {
    if (self.yb_scrollViewDirection == YBPlayerScrollViewDirectionVertical) {
        self.yb_lastOffsetY = self.contentOffset.y;
    } else {
        self.yb_lastOffsetX = self.contentOffset.x;
    }
}

/**
  The percentage of scrolling processed in vertical scrolling.
 */
- (void)_scrollViewScrollingDirectionVertical {
    CGFloat offsetY = self.contentOffset.y;
    self.yb_scrollDirection = (offsetY - self.yb_lastOffsetY > 0) ? YBPlayerScrollDirectionUp : YBPlayerScrollDirectionDown;
    self.yb_lastOffsetY = offsetY;
    if (self.yb_stopPlay) return;
    
    UIView *playerView;
    if (self.yb_containerType == YBPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.y < 0) return;
        if (!self.yb_playingIndexPath) return;
        
        UIView *cell = [self yb_getCellForIndexPath:self.yb_playingIndexPath];
        if (!cell) {
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
            return;
        }
        playerView = [cell viewWithTag:self.yb_containerViewTag];
    } else if (self.yb_containerType == YBPlayerContainerTypeView) {
        if (!self.yb_containerView) return;
        playerView = self.yb_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView top to scrollView top space.
    CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
    /// playerView bottom to scrollView bottom space.
    CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetHeight = CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.yb_scrollDirection == YBPlayerScrollDirectionUp) { /// Scroll up
        /// Player is disappearing.
        if (topSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -topSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.yb_playerDisappearingInScrollView) self.yb_playerDisappearingInScrollView(self.yb_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (topSpacing <= 0 && topSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.yb_playerWillDisappearInScrollView) self.yb_playerWillDisappearInScrollView(self.yb_playingIndexPath);
        } else if (topSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
        } else if (topSpacing > 0 && topSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(topSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.yb_playerAppearingInScrollView) self.yb_playerAppearingInScrollView(self.yb_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (topSpacing <= contentInsetHeight && topSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.yb_playerWillAppearInScrollView) self.yb_playerWillAppearInScrollView(self.yb_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.yb_playerDidAppearInScrollView) self.yb_playerDidAppearInScrollView(self.yb_playingIndexPath);
            }
        }
        
    } else if (self.yb_scrollDirection == YBPlayerScrollDirectionDown) { /// Scroll Down
        /// Player is disappearing.
        if (bottomSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -bottomSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.yb_playerDisappearingInScrollView) self.yb_playerDisappearingInScrollView(self.yb_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (bottomSpacing <= 0 && bottomSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.yb_playerWillDisappearInScrollView) self.yb_playerWillDisappearInScrollView(self.yb_playingIndexPath);
        } else if (bottomSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
        } else if (bottomSpacing > 0 && bottomSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(bottomSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.yb_playerAppearingInScrollView) self.yb_playerAppearingInScrollView(self.yb_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (bottomSpacing <= contentInsetHeight && bottomSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.yb_playerWillAppearInScrollView) self.yb_playerWillAppearInScrollView(self.yb_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.yb_playerDidAppearInScrollView) self.yb_playerDidAppearInScrollView(self.yb_playingIndexPath);
            }
        }
    }
}

/**
 The percentage of scrolling processed in horizontal scrolling.
 */
- (void)_scrollViewScrollingDirectionHorizontal {
    CGFloat offsetX = self.contentOffset.x;
    self.yb_scrollDirection = (offsetX - self.yb_lastOffsetX > 0) ? YBPlayerScrollDirectionLeft : YBPlayerScrollDirectionRight;
    self.yb_lastOffsetX = offsetX;
    if (self.yb_stopPlay) return;
    
    UIView *playerView;
    if (self.yb_containerType == YBPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.x < 0) return;
        if (!self.yb_playingIndexPath) return;
        
        UIView *cell = [self yb_getCellForIndexPath:self.yb_playingIndexPath];
        if (!cell) {
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
            return;
        }
       playerView = [cell viewWithTag:self.yb_containerViewTag];
    } else if (self.yb_containerType == YBPlayerContainerTypeView) {
        if (!self.yb_containerView) return;
        playerView = self.yb_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView left to scrollView left space.
    CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
    /// playerView bottom to scrollView right space.
    CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetWidth = CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.yb_scrollDirection == YBPlayerScrollDirectionLeft) { /// Scroll left
        /// Player is disappearing.
        if (leftSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -leftSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.yb_playerDisappearingInScrollView) self.yb_playerDisappearingInScrollView(self.yb_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (leftSpacing <= 0 && leftSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.yb_playerWillDisappearInScrollView) self.yb_playerWillDisappearInScrollView(self.yb_playingIndexPath);
        } else if (leftSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
        } else if (leftSpacing > 0 && leftSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(leftSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.yb_playerAppearingInScrollView) self.yb_playerAppearingInScrollView(self.yb_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (leftSpacing <= contentInsetWidth && leftSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.yb_playerWillAppearInScrollView) self.yb_playerWillAppearInScrollView(self.yb_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.yb_playerDidAppearInScrollView) self.yb_playerDidAppearInScrollView(self.yb_playingIndexPath);
            }
        }
        
    } else if (self.yb_scrollDirection == YBPlayerScrollDirectionRight) { /// Scroll right
        /// Player is disappearing.
        if (rightSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -rightSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.yb_playerDisappearingInScrollView) self.yb_playerDisappearingInScrollView(self.yb_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (rightSpacing <= 0 && rightSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.yb_playerWillDisappearInScrollView) self.yb_playerWillDisappearInScrollView(self.yb_playingIndexPath);
        } else if (rightSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.yb_playerDidDisappearInScrollView) self.yb_playerDidDisappearInScrollView(self.yb_playingIndexPath);
        } else if (rightSpacing > 0 && rightSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(rightSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.yb_playerAppearingInScrollView) self.yb_playerAppearingInScrollView(self.yb_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (rightSpacing <= contentInsetWidth && rightSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.yb_playerWillAppearInScrollView) self.yb_playerWillAppearInScrollView(self.yb_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.yb_playerDidAppearInScrollView) self.yb_playerDidAppearInScrollView(self.yb_playingIndexPath);
            }
        }
    }
}

/**
 Find the playing cell while the scrollDirection is vertical.
 */
- (void)_findCorrectCellWhenScrollViewDirectionVertical:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.yb_shouldAutoPlay) return;
    if (self.yb_containerType == YBPlayerContainerTypeView) return;

    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.y <= 0 && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.y <= 0 && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.yb_scrollDirection == YBPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidY = CGRectGetHeight(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView top to scrollView top space.
        CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
        /// playerView bottom to scrollView bottom space.
        CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidY - CGRectGetMidY(rect));
        NSIndexPath *indexPath = [self yb_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((topSpacing >= -(1 - self.yb_playerApperaPercent) * CGRectGetHeight(rect)) && (bottomSpacing >= -(1 - self.yb_playerApperaPercent) * CGRectGetHeight(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.yb_playingIndexPath) {
                indexPath = self.yb_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (handler) handler(finalIndexPath);
        self.yb_shouldPlayIndexPath = finalIndexPath;
    }
}

/**
 Find the playing cell while the scrollDirection is horizontal.
 */
- (void)_findCorrectCellWhenScrollViewDirectionHorizontal:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.yb_shouldAutoPlay) return;
    if (self.yb_containerType == YBPlayerContainerTypeView) return;
    
    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.x <= 0 && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.x <= 0 && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.yb_playingIndexPath || [indexPath compare:self.yb_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
            if (playerView) {
                if (handler) handler(indexPath);
                self.yb_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.yb_scrollDirection == YBPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidX = CGRectGetWidth(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.yb_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView left to scrollView top space.
        CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
        /// playerView right to scrollView top space.
        CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidX - CGRectGetMidX(rect));
        NSIndexPath *indexPath = [self yb_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((leftSpacing >= -(1 - self.yb_playerApperaPercent) * CGRectGetWidth(rect)) && (rightSpacing >= -(1 - self.yb_playerApperaPercent) * CGRectGetWidth(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.yb_playingIndexPath) {
                indexPath = self.yb_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (handler) handler(finalIndexPath);
        self.yb_shouldPlayIndexPath = finalIndexPath;
    }
}

- (BOOL)isTableView {
    return [self isKindOfClass:[UITableView class]];
}

- (BOOL)isCollectionView {
    return [self isKindOfClass:[UICollectionView class]];
}

#pragma mark - public method

- (void)yb_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (self.yb_scrollViewDirection == YBPlayerScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:handler];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:handler];
    }
}

- (void)yb_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.yb_shouldAutoPlay) return;
    @weakify(self)
    [self yb_filterShouldPlayCellWhileScrolling:^(NSIndexPath *indexPath) {
        @strongify(self)
        /// 如果当前控制器已经消失，直接return
        if (self.yb_viewControllerDisappear) return;
        if ([YBPlayerReachabilityManager sharedManager].isReachableViaWWAN && !self.yb_WWANAutoPlay) {
            /// 移动网络
            self.yb_shouldPlayIndexPath = indexPath;
            return;
        }
        if (handler) handler(indexPath);
        self.yb_playingIndexPath = indexPath;
    }];
}

- (UIView *)yb_getCellForIndexPath:(NSIndexPath *)indexPath {
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (NSIndexPath *)yb_getIndexPathForCell:(UIView *)cell {
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
        return indexPath;
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)cell];
        return indexPath;
    }
    return nil;
}

- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler {
    [self yb_scrollToRowAtIndexPath:indexPath animated:YES completionHandler:completionHandler];
}

- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler {
    [self yb_scrollToRowAtIndexPath:indexPath animateWithDuration:animated ? 0.4 : 0.0 completionHandler:completionHandler];
}

/// Scroll to indexPath with animations duration.
- (void)yb_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler {
    BOOL animated = duration > 0.0;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
}

- (void)yb_scrollViewDidEndDecelerating {
    BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
    if (scrollToScrollStop) {
        [self _scrollViewDidStopScroll];
    }
}

- (void)yb_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
        if (dragToDragStop) {
            [self _scrollViewDidStopScroll];
        }
    }
}

- (void)yb_scrollViewDidScrollToTop {
    [self _scrollViewDidStopScroll];
}

- (void)yb_scrollViewDidScroll {
    if (self.yb_scrollViewDirection == YBPlayerScrollViewDirectionVertical) {
        [self _scrollViewScrollingDirectionVertical];
    } else {
        [self _scrollViewScrollingDirectionHorizontal];
    }
}

- (void)yb_scrollViewWillBeginDragging {
    [self _scrollViewBeginDragging];
}

#pragma mark - getter

- (NSIndexPath *)yb_playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)yb_shouldPlayIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)yb_containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (YBPlayerScrollDirection)yb_scrollDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)yb_stopWhileNotVisible {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)yb_isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)yb_shouldAutoPlay {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.yb_shouldAutoPlay = YES;
    return YES;
}

- (YBPlayerScrollViewDirection)yb_scrollViewDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)yb_stopPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (YBPlayerContainerType)yb_containerType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (UIView *)yb_containerView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)yb_lastOffsetY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)yb_lastOffsetX {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void (^)(NSIndexPath * _Nonnull))yb_scrollViewDidStopScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))yb_shouldPlayIndexPathCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setYb_playingIndexPath:(NSIndexPath *)yb_playingIndexPath {
    objc_setAssociatedObject(self, @selector(yb_playingIndexPath), yb_playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (yb_playingIndexPath) self.yb_shouldPlayIndexPath = yb_playingIndexPath;
}

- (void)setYb_shouldPlayIndexPath:(NSIndexPath *)yb_shouldPlayIndexPath {
    if (self.yb_shouldPlayIndexPathCallback) self.yb_shouldPlayIndexPathCallback(yb_shouldPlayIndexPath);
    objc_setAssociatedObject(self, @selector(yb_shouldPlayIndexPath), yb_shouldPlayIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_containerViewTag:(NSInteger)yb_containerViewTag {
    objc_setAssociatedObject(self, @selector(yb_containerViewTag), @(yb_containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_scrollDirection:(YBPlayerScrollDirection)yb_scrollDirection {
    objc_setAssociatedObject(self, @selector(yb_scrollDirection), @(yb_scrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_stopWhileNotVisible:(BOOL)yb_stopWhileNotVisible {
    objc_setAssociatedObject(self, @selector(yb_stopWhileNotVisible), @(yb_stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_WWANAutoPlay:(BOOL)yb_WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(yb_isWWANAutoPlay), @(yb_WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_scrollViewDirection:(YBPlayerScrollViewDirection)yb_scrollViewDirection {
    objc_setAssociatedObject(self, @selector(yb_scrollViewDirection), @(yb_scrollViewDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_stopPlay:(BOOL)yb_stopPlay {
    objc_setAssociatedObject(self, @selector(yb_stopPlay), @(yb_stopPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_containerType:(YBPlayerContainerType)yb_containerType {
    objc_setAssociatedObject(self, @selector(yb_containerType), @(yb_containerType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_containerView:(UIView *)yb_containerView {
    objc_setAssociatedObject(self, @selector(yb_containerView), yb_containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_shouldAutoPlay:(BOOL)yb_shouldAutoPlay {
    objc_setAssociatedObject(self, @selector(yb_shouldAutoPlay), @(yb_shouldAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_lastOffsetY:(CGFloat)yb_lastOffsetY {
    objc_setAssociatedObject(self, @selector(yb_lastOffsetY), @(yb_lastOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_lastOffsetX:(CGFloat)yb_lastOffsetX {
    objc_setAssociatedObject(self, @selector(yb_lastOffsetX), @(yb_lastOffsetX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setYb_scrollViewDidStopScrollCallback:(void (^)(NSIndexPath * _Nonnull))yb_scrollViewDidStopScrollCallback {
    objc_setAssociatedObject(self, @selector(yb_scrollViewDidStopScrollCallback), yb_scrollViewDidStopScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_shouldPlayIndexPathCallback:(void (^)(NSIndexPath * _Nonnull))yb_shouldPlayIndexPathCallback {
    objc_setAssociatedObject(self, @selector(yb_shouldPlayIndexPathCallback), yb_shouldPlayIndexPathCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UIScrollView (YBPlayerCannotCalled)

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull, CGFloat))yb_playerDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))yb_playerAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))yb_playerDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))yb_playerWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))yb_playerWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))yb_playerDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)yb_playerApperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)yb_playerDisapperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (BOOL)yb_viewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setYb_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))yb_playerDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerDisappearingInScrollView), yb_playerDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))yb_playerAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerAppearingInScrollView), yb_playerAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))yb_playerDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerDidAppearInScrollView), yb_playerDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))yb_playerWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerWillDisappearInScrollView), yb_playerWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))yb_playerWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerWillAppearInScrollView), yb_playerWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))yb_playerDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(yb_playerDidDisappearInScrollView), yb_playerDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerApperaPercent:(CGFloat)yb_playerApperaPercent {
    objc_setAssociatedObject(self, @selector(yb_playerApperaPercent), @(yb_playerApperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_playerDisapperaPercent:(CGFloat)yb_playerDisapperaPercent {
    objc_setAssociatedObject(self, @selector(yb_playerDisapperaPercent), @(yb_playerDisapperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setYb_viewControllerDisappear:(BOOL)yb_viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(yb_viewControllerDisappear), @(yb_viewControllerDisappear), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

