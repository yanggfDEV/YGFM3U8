//
//  YGFM3U8VideoDownload.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @guangfu yang 16-2-17 11:20
 *
 *M3U8格式视频下载类：下载单个视频时直接使用，下载多个视频时需要写个管理单例类
 *状态改变：等待->(开始)下载，下载->暂停，暂停->(继续)下载，失败->(重新)下载；
 *总之：未完成状态下，未下载->下载，下载->暂停
 *实际去下载的时候需要考虑网络情况变化，磁盘剩余空间，甚至手机当前电量等
 */

@protocol YGFM3U8VideoDownloadDelegate <NSObject>

- (void)M3U8VideoDownloadParseFail; //M3U8解析失败回调方法
- (void)M3U8VideoDownloadParseFinish:(NSMutableArray *)segmentTimeArray;//M3U8解析成功回调方法
- (void)M3U8VideoDownloadFinish; //video下载结束回调方法
- (void)M3U8VideoDownloadFail; //video下载失败回调方法
- (void)M3U8VideoDownloadProgress:(CGFloat)progress; //video下载进度
- (void)M3U8VideoSingleDownloadFinishStartPlay;

@end

@interface YGFM3U8VideoDownload : NSObject

@property (nonatomic, assign) id<YGFM3U8VideoDownloadDelegate> delegate;
@property (nonatomic, assign) DownloadVideoState downloadState;
@property (nonatomic, strong) NSString *vid;

- (id)initWithVideoId:(NSString *)vid VideoUrl:(NSString *)videoUrl;

- (void)changeDownloadVideoState;

- (void)deleteDownloadVideo;

@end
