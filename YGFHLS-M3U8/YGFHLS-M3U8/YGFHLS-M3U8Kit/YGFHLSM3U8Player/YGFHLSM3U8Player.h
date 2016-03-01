//
//  YGFHLSM3U8Player.h
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

@import MediaPlayer;
@import AVFoundation;

/**
 *  @guangfu yang 16-2-27 11:36
 *
 *把属性都公开到.h文件里面了，为了适配广大开发者，不同的需求可以修改属性东西，也可以直接修改源代码。
 */

typedef void(^MsgBlock) (NSString *message);

@interface YGFHLSM3U8Player : UIView

@property (nonatomic, copy) MsgBlock videoDownloadFail;
@property (nonatomic, copy) MsgBlock videoDownloadFinish;
@property (nonatomic, copy) MsgBlock videoDownloadParseFail;
@property (nonatomic, copy) MsgBlock videoDownloadStateWating;
@property (nonatomic, copy) MsgBlock videoDownloadStateDownloading;
@property (nonatomic, copy) MsgBlock videoDownloadStatePausing;
@property (nonatomic, copy) MsgBlock videoDownloadStateFail;
@property (nonatomic, copy) MsgBlock videoDownloadStateFinish;

/**
 *  播放器player
 */
@property (nonatomic, retain) AVPlayer *player;

/**
 *playerLayer,可以修改frame
 */
@property (nonatomic, retain) AVPlayerLayer *playerLayer;

/**
 *  底部操作工具栏
 */
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) UISlider *progressSlider;
@property (nonatomic, retain) UISlider *volumeSlider;
@property (nonatomic, copy) NSString *videoURLStr;

/**
 *  BOOL值判断当前的状态
 */
@property (nonatomic, assign) BOOL isFullscreen;

/**
 *  显示播放时间的UILabel
 */
@property (nonatomic,retain) UILabel *timeLabel;

/**
 *  控制全屏的按钮
 */
@property (nonatomic, retain) UIButton *fullScreenBtn;

/**
 *  播放暂停按钮
 */
@property (nonatomic,retain) UIButton *playOrPauseBtn;

/**
 *  关闭按钮
 */
@property (nonatomic,retain) UIButton *closeBtn;

/* playItem */
@property (nonatomic, retain) AVPlayerItem *currentItem;

/**
 *  初始化WMPlayer的方法
 *
 *  @param frame       frame
 *  @param videoURLStr URL字符串，包括网络的和本地的URL
 *
 *  @return id类型，实际上就是WMPlayer的一个对象
 */
- (id)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr;

@end
