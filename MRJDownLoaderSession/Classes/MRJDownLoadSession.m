//
//  MRJDownLoad.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoadSession.h"

@interface MRJDownLoadSession() <NSURLSessionDataDelegate, NSURLSessionDelegate>

/// 下载地址
@property (nonatomic, strong) NSURL *downUrl;
/// 文件下载存放目录
@property (nonatomic, copy) NSString *filePath;
/// 初始化URL链接类
@property (nonatomic, strong) NSURLSessionDataTask *task;

/// 下载回调进度
@property (nonatomic, copy) void (^progressBlock)(float);
/// 下载完成回调
@property (nonatomic, copy) void (^completeBlock)(NSString *);
/// 下载失败完成回调
@property (nonatomic, copy) void (^errorBlock)(NSString *);


/// 当前文件保存长度
@property (nonatomic, assign) long long  curreLength;
/// 服务器给定下载文件长度
@property (nonatomic, assign) long long expectedContentLength;
/// 文件输入输出流，用来保存下载文件
@property (nonatomic, strong) NSOutputStream *outPutFileStream;

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
        if (![self checkLoaclFileInfo]) {
            // 下载完成
            if (self.completeBlock) {
                self.completeBlock(self.filePath);
            }
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
        
        self.expectedContentLength = response.expectedContentLength;
        // 建议保存的文件名,将在的文件保存在tmp ,系统会自动回收
        self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
        
        if (responseBlock){
            responseBlock(response);
        }
    }];
    [task resume];
}

/// 拿到本地已下载文件信息
//- (NSData *)checkLoaclFileInfo {
//    return [[NSUserDefaults standardUserDefaults] objectForKey:_filePath];
//}

/// 拿到本地已下载文件信息
- (BOOL)checkLoaclFileInfo {
    long long localFileSize = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
        localFileSize = fileDic.fileSize;
    };
    
    /// 本地文件大于服务器文件时删除本地文件，这样的情况就是服务器换文件，或者下载出错
    if (localFileSize > self.expectedContentLength) {
        localFileSize = 0;
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
    }
    
    self.curreLength = localFileSize;
    /// 如果本地文件大小和服务器文件大小相等，可认定文件已下载完成，当然还是以MD5校验为准
    if (self.curreLength == self.expectedContentLength) {
        // 下载完成
        return NO;
    }
    return YES;
}

/// 文件下载
- (void)downloadFile {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downUrl];
    /// 在请求头里有一个关键字段Range，用来告诉服务器我需要从哪里开始已下载
    /// bytes=10- 表示从10字节以后完全获取
    /// bytes=20-400 表示从20-400之间的数据
    /// bytes= -500 表示需要最后的500字节数据
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", self.curreLength] forHTTPHeaderField:@"Range"];
    //    self.task = [session downloadTaskWithRequest:request];
    self.task = [session dataTaskWithRequest:request];
    [self.task resume];
}

#pragma mark 暂停任务

/// 任务暂停
- (void)pause {
    [self.task cancel];
}

#pragma mark NSURLConnectionDataDelegate

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"start data");
    /** b. 让任务继续正常进行.(如果没有写这行代码, 将不会执行下面的代理方法.) */
    completionHandler(NSURLSessionResponseAllow);
    self.outPutFileStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.outPutFileStream open];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSLog(@"become down loadtask");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.outPutFileStream write:data.bytes maxLength:data.length];
    self.curreLength += data.length;
    float progress = (float)self.curreLength / self.expectedContentLength;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    
    if (progress == 1.0){
        [self.outPutFileStream close];
        if (self.completeBlock) {
            self.completeBlock(self.filePath);
        }
    }
    NSLog(@"receive data");
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    NSLog(@"willCacheResponse");
}

#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    
}

@end
