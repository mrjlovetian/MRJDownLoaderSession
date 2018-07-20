//
//  MRJDownLoad.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoadSession.h"

@interface MRJDownLoadSession() <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

/// 下载地址
@property (nonatomic, strong) NSURL *downUrl;
/// 文件下载存放目录
@property (nonatomic, copy) NSString *filePath;
/// 初始化URL链接类
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

/// 下载回调进度
@property (nonatomic, copy) void (^progressBlock)(float);
/// 下载完成回调
@property (nonatomic, copy) void (^completeBlock)(NSString *);
/// 下载失败完成回调
@property (nonatomic, copy) void (^errorBlock)(NSString *);

@end

@implementation MRJDownLoadSession

- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg {
    
    self.downUrl = url;
    self.progressBlock = progress;
    self.completeBlock = complete;
    self.errorBlock = errorMsg;
    
    // 检查远程服务器文件大小
    [self checkFileWithUrl:url responseBlock:^(NSURLResponse *response) {
        // 判断在本地是否有文件
        if ([self checkLoaclFileInfo]) {
            // 下载完成
            NSLog(@"下载完成");
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
            self.task = [session downloadTaskWithResumeData:[self checkLoaclFileInfo]];
            [self.task resume];
            return;
        };
        // 开始下载
        [self downloadFile];
    }];
}

#pragma mark 私有方法
/// 通过URL检查远程服务器文件信息
- (void)checkFileWithUrl:(NSURL *)url responseBlock:(void (^)(NSURLResponse *response))responseBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 建议保存的文件名,将在的文件保存在tmp ,系统会自动回收
        self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
        
        if (responseBlock){
            responseBlock(response);
        }
    }];
    [task resume];
}

/// 拿到本地已下载文件信息
- (NSData *)checkLoaclFileInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:_filePath];
}

/// 文件下载
- (void)downloadFile {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downUrl];
    /// 在请求头里有一个关键字段Range，用来告诉服务器我需要从哪里开始已下载
    /// bytes=10- 表示从10字节以后完全获取
    /// bytes=20-400 表示从20-400之间的数据
    /// bytes= -500 表示需要最后的500字节数据
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    self.task = [session downloadTaskWithRequest:request];
    [self.task resume];
}

#pragma mark 暂停任务
    
/// 任务暂停
- (void)pause {
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        NSLog(@"filepath = %@", _filePath);
        [[NSUserDefaults standardUserDefaults] setObject:resumeData forKey:_filePath];
        self.task = nil;
    }];
}

#pragma mark NSURLConnectionDataDelegate
    
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    if (self.completeBlock) {
        NSError *error = nil;
        NSURL *fileDownUrl = [NSURL fileURLWithPath:self.filePath isDirectory:NO];;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileDownUrl error:&error];
        NSLog(@"nerror=%@\nfileDownUrl=%@-----\n%@", error, fileDownUrl, self.filePath);
        self.completeBlock(location.path);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
   
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}
    
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    if (self.errorBlock) {
        self.errorBlock(@"下载出错了");
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    
}


@end
