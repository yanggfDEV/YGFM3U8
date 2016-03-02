//
//  YGFM3U8SegmentInfo.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @guangfu yang 16-2-27 10:38
 *
 *M3U8一个视频小片段信息类
 **/

@interface YGFM3U8SegmentInfo : NSObject

@property (nonatomic, assign) NSInteger index; //小片段的索引下标
@property (nonatomic, assign) NSInteger duration; //小片段的totalTime
@property (nonatomic, strong) NSString  *url; //小片段的资源路径

@end
