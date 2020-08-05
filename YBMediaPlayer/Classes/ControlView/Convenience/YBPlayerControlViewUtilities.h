//
//  YBPlayerControlViewUtilities.h
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 刘海屏机型判断
#define YBIsNotchedScreen [YBPlayerControlViewUtilities isNotchedScreen]


#ifndef YBUIImageMake
    #define YBUIImageMake(file)          [YBPlayerControlViewUtilities imageNamed:file]
#endif

// 屏幕的宽
#ifndef DEVICE_WIDTH
    #define DEVICE_WIDTH                 MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#endif

// 屏幕的高
#ifndef DEVICE_HEIGHT
    #define DEVICE_HEIGHT                MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)
#endif

// 是否是全面屏
#ifndef IS_NOTCHED_SCREEN
    #define IS_NOTCHED_SCREEN            [YBPlayerControlViewUtilities isNotchedScreen]
#endif

// 安全区域缩进
#ifndef SafeAreaInsetsForDevice
    #define SafeAreaInsetsForDevice      [YBPlayerControlViewUtilities safeAreaInsetsForDeviceScreen]
#endif

NS_ASSUME_NONNULL_BEGIN


@interface YBPlayerControlViewUtilities : NSObject

+ (UIEdgeInsets)safeAreaInsetsForDeviceScreen;

+ (BOOL)isNotchedScreen;

+ (CGSize)screenSizeFor58Inch;

+ (BOOL)is58InchScreen;

+ (BOOL)isiPad;

+ (NSString *)convertTimeSecond:(NSInteger)timeSecond;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
