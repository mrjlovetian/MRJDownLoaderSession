//
//  MRJDownLoad.h
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRJDownLoadSession : NSObject

/*
 * url 具体的下载URL
 * progress 下载进度回调
 * complete 下载完成后回调下载路径
 * errorMsg 下载出错回调错误信息
 */
- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg;

/*
 * 暂停下载
 */
- (void)pause;

@end
