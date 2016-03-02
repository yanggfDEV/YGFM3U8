//
//  YGFM3U8Analyse.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * @guangfu yang 16-2-27 10:30
 * M3U8字符串解析类
 **/

@class YGFM3U8Analyse;
@class YGFM3U8SegmentList;

@protocol YGFM3U8AnalyseDelegate <NSObject>

- (void)M3U8AnalyseFinish:(NSMutableArray *)segmentTimeArray; //解析结束
- (void)M3U8AnalyseFail:(NSError *)error; //解析失败

@end

@interface YGFM3U8Analyse : NSObject

@property (nonatomic, assign) id<YGFM3U8AnalyseDelegate> delegate;
@property (nonatomic, strong) YGFM3U8SegmentList *segmentList;
@property (nonatomic, assign) NSInteger totalSeconds;

- (void)analyseVideoUrl:(NSString *)videoUrl;

@end
