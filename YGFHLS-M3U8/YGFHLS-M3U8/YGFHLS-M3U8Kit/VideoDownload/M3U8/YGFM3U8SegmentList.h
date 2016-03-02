//
//  YGFM3U8SegmentList.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGFM3U8SegmentInfo.h"

/**
 * @guangfu yang 16-2-27 10:42
 *
 *M3U8视频小片段合集类
 */

@interface YGFM3U8SegmentList : NSObject

@property (nonatomic, strong) NSMutableArray *segments; //用于存小片段的容器

- (id)initWithSegments:(NSMutableArray *)segments; //初始化M3U8视频小片段合集类

- (YGFM3U8SegmentInfo *)getSegmentWithIndex:(NSInteger)index; //通过小片段的索引取出小片段，这用于下载资源

@end
