//
//  MRJDownLoaderManager.m
//  DownloadManager_Example
//
//  Created by tops on 2018/7/17.
//  Copyright © 2018年 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJDownLoaderSessionManager.h"
#import "MRJDownLoadSession.h"

@interface MRJDownLoaderSessionManager()

@property (nonatomic, strong) NSMutableDictionary *downCache;

@end

@implementation MRJDownLoaderSessionManager

+ (instancetype)shareDownLoaderManager {
    static MRJDownLoaderSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MRJDownLoaderSessionManager alloc] init];
    });
    return manager;
}

- (void)downLoadWithUrl:(NSURL *)url progress:(void (^)(float progress))progress complete:(void (^)(NSString *filePath))complete errorMsg:(void(^)(NSString *errorMsg))errorMsg {
    
    if (self.downCache[url.path]){
        return;
    }
    MRJDownLoadSession *downLoader = [[MRJDownLoadSession alloc] init];
    [downLoader downLoadWithUrl:url progress:progress complete:complete errorMsg:errorMsg];
    [self.downCache setObject:downLoader forKey:url.path];
}
    
- (void)pause:(NSURL *)url {
    MRJDownLoadSession *downLoader = self.downCache[url.path];
    [downLoader pause];
    [self.downCache removeObjectForKey:url.path];
}

- (NSMutableDictionary *)downCache {
    if (!_downCache){
        _downCache = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _downCache;
}
    
@end
