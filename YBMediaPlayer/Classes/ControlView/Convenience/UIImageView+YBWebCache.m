//
//  UIImageView+YBWebCache.m
//  YiBanClient
//
//  Created by Sun on 2019/12/25.
//  Copyright © 2019 Qing Class. All rights reserved.
//

#import "UIImageView+YBWebCache.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation YBImageDownloader

- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(YBDownloadProgressBlock)progress
                         finished:(YBDownLoadDataCallBack)finished {
    self.progressBlock = progress;
    self.callbackOnFinished = finished;
    
    if ([NSURL URLWithString:url] == nil) {
        if (finished) { finished(nil, nil); }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:60];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    self.session = [NSURLSession sessionWithConfiguration:config
                                                 delegate:self
                                            delegateQueue:queue];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    [task resume];
    self.task = task;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
    
    if (self.callbackOnFinished) {
        self.callbackOnFinished(data, nil);
        
        // 防止重复调用
        self.callbackOnFinished = nil;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.currentLength = totalBytesWritten;
    self.totalLength = totalBytesExpectedToWrite;
    
    if (self.progressBlock) {
        self.progressBlock(self.totalLength, self.currentLength);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([error code] != NSURLErrorCancelled) {
        if (self.callbackOnFinished) {
            self.callbackOnFinished(nil, error);
        }
        self.callbackOnFinished = nil;
    }
}

@end

@interface NSString (md5)

+ (NSString *)cachedFileNameForKey:(NSString *)key;
+ (NSString *)yb_cachePath;
+ (NSString *)yb_keyForRequest:(NSURLRequest *)request;

@end

@implementation NSString (md5)

+ (NSString *)yb_keyForRequest:(NSURLRequest *)request{
    return request.URL.absoluteString;
}

+ (NSString *)yb_cachePath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@/%@",cachePath,@"default",@"com.hackemist.SDWebImageCache.default"];
    return directoryPath;
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}

@end

@interface UIApplication (YBCacheImage)

@property (nonatomic, strong, readonly) NSMutableDictionary *yb_cacheFaileTimes;

- (UIImage *)yb_cacheImageForRequest:(NSURLRequest *)request;
- (void)yb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
- (void)yb_cacheFailRequest:(NSURLRequest *)request;
- (NSUInteger)yb_failTimesForRequest:(NSURLRequest *)request;

@end

@implementation UIApplication (YBCacheImage)

- (NSMutableDictionary *)yb_cacheFaileTimes {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, _cmd);
    if (!dict) {
        dict = [[NSMutableDictionary alloc] init];
    }
    return dict;
}

- (void)setYb_cacheFaileTimes:(NSMutableDictionary *)yb_cacheFaileTimes {
    objc_setAssociatedObject(self, @selector(yb_cacheFaileTimes), yb_cacheFaileTimes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)yb_clearCache {
    [self.yb_cacheFaileTimes removeAllObjects];
    self.yb_cacheFaileTimes = nil;
}

- (void)yb_clearDiskCaches {
    NSString *directoryPath = [NSString yb_cachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        dispatch_queue_t ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);
        dispatch_async(ioQueue, ^{
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        });
    }
    [self yb_clearCache];
}

- (UIImage *)yb_cacheImageForRequest:(NSURLRequest *)request {
    if (request) {
        NSString *directoryPath = [NSString yb_cachePath];
        NSString *path = [NSString stringWithFormat:@"%@/%@", directoryPath, [NSString cachedFileNameForKey:[NSString yb_keyForRequest:request]]];
        return [UIImage imageWithContentsOfFile:path];
    }
    return nil;
}

- (NSUInteger)yb_failTimesForRequest:(NSURLRequest *)request {
    NSNumber *faileTimes = [self.yb_cacheFaileTimes objectForKey:[NSString cachedFileNameForKey:[NSString yb_keyForRequest:request]]];
    if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
        return faileTimes.integerValue;
    }
    return 0;
}

- (void)yb_cacheFailRequest:(NSURLRequest *)request {
    NSNumber *faileTimes = [self.yb_cacheFaileTimes objectForKey:[NSString cachedFileNameForKey:[NSString yb_keyForRequest:request]]];
    NSUInteger times = 0;
    if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
        times = [faileTimes integerValue];
    }
    
    times++;
    
    [self.yb_cacheFaileTimes setObject:@(times) forKey:[NSString cachedFileNameForKey:[NSString yb_keyForRequest:request]]];
}

- (void)yb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    if (!image || !request) { return; }
    
    NSString *directoryPath = [NSString yb_cachePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) { return; }
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", directoryPath, [NSString cachedFileNameForKey:[NSString yb_keyForRequest:request]]];
    NSData *data = UIImagePNGRepresentation(image);
    if (data) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    }
}

@end


@implementation UIImageView (YBCache)

#pragma mark - getter

- (YBImageBlock)completion
{
    return objc_getAssociatedObject(self, _cmd);
}

- (YBImageDownloader *)imageDownloader
{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSUInteger)attemptToReloadTimesForFailedURL
{
    NSUInteger count = [objc_getAssociatedObject(self, _cmd) integerValue];
    if (count == 0) {  count = 2; }
    return count;
}

- (BOOL)shouldAutoClipImageToViewSize
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setCompletion:(YBImageBlock)completion
{
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setImageDownloader:(YBImageDownloader *)imageDownloader
{
    objc_setAssociatedObject(self, @selector(imageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setAttemptToReloadTimesForFailedURL:(NSUInteger)attemptToReloadTimesForFailedURL
{
    objc_setAssociatedObject(self, @selector(attemptToReloadTimesForFailedURL), @(attemptToReloadTimesForFailedURL), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setShouldAutoClipImageToViewSize:(BOOL)shouldAutoClipImageToViewSize
{
    objc_setAssociatedObject(self, @selector(shouldAutoClipImageToViewSize), @(shouldAutoClipImageToViewSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public method

- (void)setImageWithURLString:(NSString *)url
         placeholderImageName:(NSString *)placeholderImageName {
    return [self setImageWithURLString:url placeholderImageName:placeholderImageName completion:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage {
    return [self setImageWithURLString:url placeholder:placeholderImage completion:nil];
}

- (void)setImageWithURLString:(NSString *)url
         placeholderImageName:(NSString *)placeholderImage
                   completion:(void (^)(UIImage *image))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource:placeholderImage ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image == nil) { image = [UIImage imageNamed:placeholderImage]; }
    
    [self setImageWithURLString:url placeholder:image completion:completion];
}

- (void)setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImageName
                   completion:(void (^)(UIImage *image))completion {
    [self.layer removeAllAnimations];
    self.completion = completion;
    
    if (url == nil || [url isKindOfClass:[NSNull class]] || (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])) {
        [self setImage:placeholderImageName isFromCache:YES];
        
        if (completion) {
            self.completion(self.image);
        }
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self downloadWithReqeust:request holder:placeholderImageName];
}

#pragma mark - private method

- (void)downloadWithReqeust:(NSURLRequest *)theRequest holder:(UIImage *)holder {
    UIImage *cachedImage = [[UIApplication sharedApplication] yb_cacheImageForRequest:theRequest];
    
    if (cachedImage) {
        [self setImage:cachedImage isFromCache:YES];
        if (self.completion) {
            self.completion(cachedImage);
        }
        return;
    }
    
    [self setImage:holder isFromCache:YES];
    
    if ([[UIApplication sharedApplication] yb_failTimesForRequest:theRequest] >= self.attemptToReloadTimesForFailedURL) {
        return;
    }
    
    [self cancelRequest];
    self.imageDownloader = nil;
    
    __weak __typeof(self) weakSelf = self;
    
    self.imageDownloader = [[YBImageDownloader alloc] init];
    [self.imageDownloader startDownloadImageWithUrl:theRequest.URL.absoluteString progress:nil finished:^(NSData *data, NSError *error) {
        // success
        if (data != nil && error == nil) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *finalImage = image;
                
                if (image) {
                    if (weakSelf.shouldAutoClipImageToViewSize) {
                        // cutting
                        if (fabs(weakSelf.frame.size.width - image.size.width) != 0
                            && fabs(weakSelf.frame.size.height - image.size.height) != 0) {
                            finalImage = [self clipImage:image toSize:weakSelf.frame.size isScaleToMax:YES];
                        }
                    }
                    
                    [[UIApplication sharedApplication] yb_cacheImage:finalImage forRequest:theRequest];
                } else {
                    [[UIApplication sharedApplication] yb_cacheFailRequest:theRequest];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finalImage) {
                        [weakSelf setImage:finalImage isFromCache:NO];
                        
                        if (weakSelf.completion) {
                            weakSelf.completion(weakSelf.image);
                        }
                    } else {// error data
                        if (weakSelf.completion) {
                            weakSelf.completion(weakSelf.image);
                        }
                    }
                });
            });
        } else { // error
            [[UIApplication sharedApplication] yb_cacheFailRequest:theRequest];
            
            if (weakSelf.completion) {
                weakSelf.completion(weakSelf.image);
            }
        }
    }];
}

- (void)setImage:(UIImage *)image isFromCache:(BOOL)isFromCache {
    self.image = image;
    if (!isFromCache) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.6f];
        [animation setType:kCATransitionFade];
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"transition"];
    }
}

- (void)cancelRequest {
    [self.imageDownloader.task cancel];
}

- (UIImage *)clipImage:(UIImage *)image toSize:(CGSize)size isScaleToMax:(BOOL)isScaleToMax {
    CGFloat scale =  [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGSize aspectFitSize = CGSizeZero;
    if (image.size.width != 0 && image.size.height != 0) {
        CGFloat rateWidth = size.width / image.size.width;
        CGFloat rateHeight = size.height / image.size.height;
        
        CGFloat rate = isScaleToMax ? MAX(rateHeight, rateWidth) : MIN(rateHeight, rateWidth);
        aspectFitSize = CGSizeMake(image.size.width * rate, image.size.height * rate);
    }
    
    [image drawInRect:CGRectMake(0, 0, aspectFitSize.width, aspectFitSize.height)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

@end
