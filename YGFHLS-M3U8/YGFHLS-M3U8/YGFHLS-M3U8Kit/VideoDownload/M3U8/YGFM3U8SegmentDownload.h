//
//  YGFM3U8SegmentDownload.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @guangfu yang 16-2-27 10:46
 *
 *M3U8一个视频小片段下载类
 *这个类中用到文件下载功能
 */

@class YGFM3U8SegmentDownload;

@protocol YGFM3U8SegmentDownloadDelegate <NSObject>

- (void)M3U8SegmentDownloadFinished:(YGFM3U8SegmentDownload *)segmentDownload  listIndex:(NSInteger)listIndex; //小片段下载结束回调方法
- (void)M3U8SegmentDownloadFailed:(YGFM3U8SegmentDownload *)segmentDownload; //小片段下载失败回调方法
- (void)M3U8SegmentDownloadProgress:(CGFloat)progress; //小片段下载progress回调方法

- (void)M3U8SegmentSingleDownloadFinished:(YGFM3U8SegmentDownload *)segmentDownload;

- (void)M3U8ProgressStartPlayer;

@end

@interface YGFM3U8SegmentDownload : NSObject

@property (nonatomic, assign) id<YGFM3U8SegmentDownloadDelegate> delegate;

- (id)initWithUrl:(NSString *)url FilePath:(NSString *)path FileName:(NSString *)name;

- (void)start;

- (void)pause;

- (void)cancel;

@end
