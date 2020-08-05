//
//  YBPlayerLogManager.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "YBPlayerLogManager.h"

static BOOL kLogEnable = NO;

@implementation YBPlayerLogManager

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (NSString *)version {
    return @"1.1.3";
}

+ (void)logWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {
        NSLog(@"%s[%d]%@", function, lineNumber, formatString);
    }
}

@end
