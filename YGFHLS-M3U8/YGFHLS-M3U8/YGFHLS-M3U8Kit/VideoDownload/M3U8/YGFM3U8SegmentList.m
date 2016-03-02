//
//  YGFM3U8SegmentList.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFM3U8SegmentList.h"

@implementation YGFM3U8SegmentList

- (id)initWithSegments:(NSMutableArray *)segments {
    if(self = [super init]){
        self.segments = segments;
    }
    return self;
}

- (YGFM3U8SegmentInfo *)getSegmentWithIndex:(NSInteger)index {
    return [self.segments objectAtIndex:index];
}

@end
