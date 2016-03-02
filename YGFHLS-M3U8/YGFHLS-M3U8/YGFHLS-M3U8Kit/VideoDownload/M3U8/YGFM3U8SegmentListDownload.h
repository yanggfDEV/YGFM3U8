//
//  YGFM3U8SegmentListDownload.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @guangfu yang 16-2-27 10:59
 *
 *M3U8视频小片段合集下载类
 *如果有数据需要传递到外层的信息有：视频总大小，当前下载大小或百分比，当前下载速度
 *为了便于管理，同一时间只下载一个小片段；
 *因为每一段视频的大小都是不一样的，所以下载完成之前不知道具体视频大小
 **/

@class YGFM3U8SegmentList;
@class YGFM3U8SegmentDownload;

@protocol YGFM3U8SegmentListDownloadDelegate <NSObject>

- (void)M3U8SegmentListDownloadFinished;
- (void)M3U8SegmentListDownloadFailed;
- (void)M3U8SegmentListDownloadProgress:(CGFloat)progress;
- (void)M3U8SegmentSingleDownloadFinished;

@end

@interface YGFM3U8SegmentListDownload : NSObject

@property (nonatomic, assign) id<YGFM3U8SegmentListDownloadDelegate> delegate;
@property (nonatomic, strong) YGFM3U8SegmentList *segmentList;
@property (nonatomic, strong) NSString *vid;

- (id)initWithSegmentList:(YGFM3U8SegmentList *)segmentList;

- (void)startDownloadVideo;

- (void)pauseDownloadVideo;

- (void)cancelDownloadVideo;

@end
