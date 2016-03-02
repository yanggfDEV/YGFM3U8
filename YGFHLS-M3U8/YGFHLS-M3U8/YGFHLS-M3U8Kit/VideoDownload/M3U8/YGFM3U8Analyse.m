//
//  YGFM3U8Analyse.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFM3U8Analyse.h"
#import "YGFM3U8SegmentList.h"
#import "YGFM3U8SegmentInfo.h"
#import "Reachability.h"

@implementation YGFM3U8Analyse

- (void)analyseVideoUrl:(NSString *)videoUrl {
    NSMutableArray *durationArr = [NSMutableArray array];
    NSRange rangeOfM3U8 = [videoUrl rangeOfString:@"m3u8"];
    if (rangeOfM3U8.location == NSNotFound) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFail:)]) {
            NSError *err = [NSError errorWithDomain:videoUrl code:M3U8AnalyseFailNotM3U8Url userInfo:nil];
            [self.delegate M3U8AnalyseFail:err];
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:videoUrl];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *data = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
    if (!data) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFail:)]) {
            NSError *err = [NSError errorWithDomain:videoUrl code:M3U8AnalyseFailNetworkUnConnection userInfo:nil];
            [self.delegate M3U8AnalyseFail:err];
        }
        return;
    }
    
    NSString *remainData = data;
    NSLog(@"解析前的---------original data is: %@",data);
    
    NSRange httpRange = [remainData rangeOfString:@"http"];
    if(httpRange.location == NSNotFound){
        //暂时只针对腾讯视频
        NSString *newString = @"av";
        NSRange range = [videoUrl rangeOfString:@"playlist.av.m3u8"];
        if (range.location != NSNotFound) {
            newString = [NSString stringWithFormat:@"%@%@",[videoUrl substringToIndex:range.location],@"av"];
        }
        remainData = [remainData stringByReplacingOccurrencesOfString:@"av" withString:newString];
    }
    
    NSMutableArray *segments = [NSMutableArray array];
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    NSInteger segmentIndex = 0;
    NSInteger totalSeconds = 0;
    while (segmentRange.location != NSNotFound) {
        YGFM3U8SegmentInfo *segment = [[YGFM3U8SegmentInfo alloc] init];
        //读取片段时长
        NSRange commaRange = [remainData rangeOfString:@","];
        NSString *value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        totalSeconds+=segment.duration;
        remainData = [remainData substringFromIndex:commaRange.location];
        //读取片段url
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        NSString *linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.url = linkurl;
        segment.index = segmentIndex;
        //
        segmentIndex++;
        [segments addObject:segment];
        [durationArr addObject:[NSString stringWithFormat:@"%ld",(long)segment.duration]];
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    
    YGFM3U8SegmentList *segmentList = [[YGFM3U8SegmentList alloc] initWithSegments:segments];
    self.segmentList = segmentList;
    self.totalSeconds = totalSeconds;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(M3U8AnalyseFinish:)]){
        [self.delegate M3U8AnalyseFinish:durationArr];
    }
}

/* m3u8文件格式示例
 
 #EXTM3U
 #EXT-X-TARGETDURATION:30
 #EXT-X-VERSION:2
 #EXT-X-DISCONTINUITY
 #EXTINF:10,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_0.ts?KM=14eb49fe4969126c6&start=0&end=10&ts=10&html5=1&seg_no=0&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_1.ts?KM=14eb49fe4969126c6&start=10&end=30&ts=20&html5=1&seg_no=1&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_2.ts?KM=14eb49fe4969126c6&start=30&end=50&ts=20&html5=1&seg_no=2&seg_time=0
 #EXTINF:20,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_3.ts?KM=14eb49fe4969126c6&start=50&end=70&ts=20&html5=1&seg_no=3&seg_time=0
 #EXTINF:24,
 http://f.youku.com/player/getMpegtsPath/st/flv/fileid/03000201004F4BC6AFD0C202E26EEEB41666A0-C93C-D6C9-9FFA-33424A776707/ipad0_4.ts?KM=14eb49fe4969126c6&start=70&end=98&ts=24&html5=1&seg_no=4&seg_time=0
 #EXT-X-ENDLIST
 */

@end
