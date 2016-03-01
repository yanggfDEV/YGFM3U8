//
//  YGFParameterDetails.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#ifndef YGFParameterDetails_h
#define YGFParameterDetails_h

#define SCREEN_HEIGHT_OF_IPHONE5        568
#define SCREEN_HEIGHT_OF_IPHONE6        667
#define SCREEN_HEIGHT_OF_IPHONE6PLUS    736

//frame的一些属性
#define SCREEN_BOUNDS               [UIScreen mainScreen].bounds
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                [UIScreen mainScreen].bounds.size.width
#define IS4InchScreen               (SCREEN_HEIGHT == SCREEN_HEIGHT_OF_IPHONE5)
#define ISIPHONE6                   (SCREEN_HEIGHT == SCREEN_HEIGHT_OF_IPHONE6)
#define ISIPHONE6PLUS               (SCREEN_HEIGHT == SCREEN_HEIGHT_OF_IPHONE6PLUS)

#define ImageNamed(_pointer) [UIImage imageNamed:_pointer]

// make weak object
#define fzweak(x, weakX) try{}@finally{}; __weak __typeof(x) weakX = x;
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(self) __strong strongSelf = self;

#define STRONGSELFFor(object) typeof(object) __strong strongSelf = object;

//文件关键字
#define kPathDownload    @"DownloadVideos"
#define kTestDownloadingFileSuffix @"_etc"
#define kDownloadVideoId @"TTT"
#define kDownloadVideoUrl [NSString stringWithFormat:@"http://127.0.0.1:54321/%@/movie.m3u8",kDownloadVideoId]
#define kTempDownloadVideo @"tempVideo.ts"


#endif /* YGFParameterDetails_h */
