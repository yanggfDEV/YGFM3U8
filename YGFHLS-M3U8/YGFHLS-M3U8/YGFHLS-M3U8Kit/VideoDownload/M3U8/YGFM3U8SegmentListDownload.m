//
//  YGFM3U8SegmentListDownload.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFM3U8SegmentListDownload.h"
#import "YGFM3U8SegmentList.h"
#import "YGFM3U8SegmentDownload.h"

@interface YGFM3U8SegmentListDownload ()<YGFM3U8SegmentDownloadDelegate>

@property (strong, nonatomic) NSMutableArray *downloadArray;

@end

@implementation YGFM3U8SegmentListDownload

- (id)initWithSegmentList:(YGFM3U8SegmentList *)segmentList {
    if(self = [super init]){
        self.segmentList = segmentList;
    }
    return self;
}

- (void)startDownloadVideo {
    if (!_downloadArray) {
        self.downloadArray = [NSMutableArray array];
        NSInteger count = [self.segmentList.segments count];
        for (int i=0;i<count;i++) {
            NSString *filename = [NSString stringWithFormat:@"id%d.ts",i];
            YGFM3U8SegmentInfo *segment = [self.segmentList getSegmentWithIndex:i];
            YGFM3U8SegmentDownload *segmentDownload = [[YGFM3U8SegmentDownload alloc] initWithUrl:segment.url FilePath:self.vid FileName:filename];
            segmentDownload.delegate = self;
            [_downloadArray addObject:segmentDownload];
        }
    }
    if ([_downloadArray count]) {
        YGFM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj start];
        NSLog(@"========startDownloadVideo");
    }
}

- (void)pauseDownloadVideo {
    if([_downloadArray count]){
        YGFM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj pause];
        NSLog(@"=======pauseDownloadVideo");
    }
}

- (void)cancelDownloadVideo {
    if([_downloadArray count]){
        YGFM3U8SegmentDownload *firstObj = [_downloadArray firstObject];
        [firstObj cancel];
        NSLog(@"=======cancelDownloadVideo");
    }
}

- (void)createLocalM3U8File:(NSInteger)index {
    if (self.segmentList) {
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.vid];
        NSString *fullPath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:54321/%@/",self.vid];
        NSInteger count = [self.segmentList.segments count];
        //填充片段数据
        if (index + 1 == count) {
            for (int i = 0;i<count;i++) {
                NSString *filename = [NSString stringWithFormat:@"id%d.ts",i];
                YGFM3U8SegmentInfo *segInfo = [self.segmentList getSegmentWithIndex:i];
                NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
                NSString *url = [segmentPrefix stringByAppendingString:filename];
                head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
            }
        } else {
            NSString *filename = [NSString stringWithFormat:@"id%ld.ts",index];
            YGFM3U8SegmentInfo *segInfo = [self.segmentList getSegmentWithIndex:index];
            NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            NSString *url = [segmentPrefix stringByAppendingString:filename];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        [writer writeToFile:fullPath atomically:YES];
    }
}

//创建临时M3U8
- (void)createKTempLocalM3U8File {
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.vid];
    NSString *fullPath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
    //创建文件头部
    NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
    NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:54321/%@/",self.vid];
//    NSInteger count = [self.segmentList.segments count];
//    //填充片段数据
//    if (index + 1 == count) {
//        for (int i = 0;i<count;i++) {
//            NSString *filename = [NSString stringWithFormat:@"id%d.ts",i];
//            YGFM3U8SegmentInfo *segInfo = [self.segmentList getSegmentWithIndex:i];
//            NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
//            NSString *url = [segmentPrefix stringByAppendingString:filename];
//            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
//        }
//    } else {
        NSString *filename = kTempDownloadVideo;
//        YGFM3U8SegmentInfo *segInfo = [self.segmentList getSegmentWithIndex:index];
//        NSString *length = [NSString stringWithFormat:@"#EXTINF:30,\n",(long)segInfo.duration];
        NSString *url = [segmentPrefix stringByAppendingString:filename];
        head = [NSString stringWithFormat:@"%@%@\n",head,url];
//    }
    //创建尾部
    NSString* end = @"#EXT-X-ENDLIST";
    head = [head stringByAppendingString:end];
    NSMutableData *writer = [[NSMutableData alloc] init];
    [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    [writer writeToFile:fullPath atomically:YES];

}

#pragma mark --- SCM3U8SegmentDownloadDelegate ---
- (void)M3U8SegmentDownloadProgress:(CGFloat)progress {
    CGFloat oneSegmentDownloadProgress = progress*1.0/(float)self.segmentList.segments.count;
    CGFloat totalProgress = (oneSegmentDownloadProgress+(float)(self.segmentList.segments.count-_downloadArray.count)/(float)self.segmentList.segments.count)*100.0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadProgress:)]) {
        [self.delegate M3U8SegmentListDownloadProgress:totalProgress];
    }
    [self createKTempLocalM3U8File];
    
}

- (void)M3U8SegmentDownloadFinished:(YGFM3U8SegmentDownload *)segmentDownload listIndex:(NSInteger)listIndex {
    /**
     * @guangfu yang 16-2-27 11:17
     *
     * 1:[self startDownloadVideo]; //这段代码注掉的原因：让播放器控制下载
     * 2:[self createLocalM3U8File]; //这段代码注掉的原因：实现边下边播
     * 由于1和2的逻辑，在这实现了边下边播，播放器控制下载
     **/
    [self createLocalM3U8File:listIndex];
    [_downloadArray removeObject:segmentDownload]; //小片段下载完毕，移出下载池
    if ([_downloadArray count]) {
        //        [self startDownloadVideo]; //这段代码注掉的原因：让播放器控制下载
    } else {
        //        [self createLocalM3U8File]; //这段代码注掉的原因：实现边下边播
        if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadFinished)]){
            [self.delegate M3U8SegmentListDownloadFinished];
        }
    }
}

- (void)M3U8SegmentDownloadFailed:(YGFM3U8SegmentDownload *)segmentDownload {
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentListDownloadFailed)]){
        [self.delegate M3U8SegmentListDownloadFailed];
    }
}

//添加的暂停方法
- (void)M3U8SegmentSingleDownloadFinished:(YGFM3U8SegmentDownload *)segmentDownload {
    [self pauseDownloadVideo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentSingleDownloadFinished)]) {
        [self.delegate M3U8SegmentSingleDownloadFinished];
    }
}

@end
