//
//  YGFHLSM3U8Player.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFHLSM3U8Player.h"
#import "YGFM3U8VideoDownload.h"

#define YGFVideoSrcName(file) [@"YGFHLSM3U8Player.bundle" stringByAppendingPathComponent:file]
#define YGFVideoFrameworkSrcName(file) [@"Frameworks/YGFPlayer.framework/YGFHLSM3U8Player.bundle" stringByAppendingPathComponent:file]

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface YGFHLSM3U8Player ()<YGFM3U8VideoDownloadDelegate>
@property (nonatomic, strong) YGFM3U8VideoDownload *videoDownload;

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint secondPoint;
@property (nonatomic, retain) NSTimer *durationTimer;
@property (nonatomic, retain) NSTimer *autoDismissTimer;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) NSInteger playingTime;
@property (nonatomic, assign) NSInteger videoTotalTime;
@property (nonatomic, strong) NSMutableArray *videoSegmentArray;
@property (nonatomic, strong) NSString *m3u8_url;
@property (nonatomic, assign) NSInteger videoDownloadCount;//控制下载片段的数
@property (nonatomic, assign) BOOL videoDownloadFinished;

@end

@implementation YGFHLSM3U8Player
{
    UISlider *systemSlider;
    
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString {
    if ([urlString containsString:@"http"]) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    } else {
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:urlString] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr {
    if ((self = [super init])) {
        //初始化view
        [self setYGFHLSM3U8PlayerView:frame videoURLStr:videoURLStr];
        //判断M3U8文件是否存在
        [self findM3U8File];
    }
    return self;
}

- (void)setData {
    self.videoTotalTime = 0;
    self.videoDownloadCount = 0;
    self.videoSegmentArray = [NSMutableArray array];
    self.videoDownloadFinished = NO;
}

- (void)setYGFHLSM3U8PlayerView:(CGRect)frame videoURLStr:(NSString *)videoURLStr {
    [self setData];
    self.m3u8_url = videoURLStr;
    
    self.frame = frame;
    self.backgroundColor = [UIColor blackColor];
    self.currentItem = [self getPlayItemWithURLString:kDownloadVideoUrl];
    //AVPlayer
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    //AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.layer.bounds;
    //        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_playerLayer];
    
    //bottomView
    self.bottomView = [[UIView alloc]init];
    [self addSubview:self.bottomView];
    //autoLayout bottomView
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self).with.offset(0);
        
    }];
    [self setAutoresizesSubviews:NO];
    //_playOrPauseBtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"pause")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"pause")] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"play")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"play")] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    //autoLayout _playOrPauseBtn
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(40);
        
    }];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    [self addSubview:volumeView];
    [volumeView sizeToFit];
    
    systemSlider = [[UISlider alloc]init];
    systemSlider.backgroundColor = [UIColor clearColor];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            systemSlider = (UISlider *)view;
        }
    }
    systemSlider.autoresizesSubviews = NO;
    systemSlider.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:systemSlider];
    systemSlider.hidden = YES;
    
    self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.volumeSlider.tag = 1000;
    self.volumeSlider.hidden = YES;
    self.volumeSlider.minimumValue = systemSlider.minimumValue;
    self.volumeSlider.maximumValue = systemSlider.maximumValue;
    self.volumeSlider.value = systemSlider.value;
    [self.volumeSlider addTarget:self action:@selector(updateSystemVolumeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.volumeSlider];
    
    //slider
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:YGFVideoSrcName(@"dot")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"dot")]  forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    self.progressSlider.value = 0.0;//指定初始值
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.progressSlider];
    
    //autoLayout slider
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.bottomView).with.offset(0);
    }];
    
    //_fullScreenBtn
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"fullscreen")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"fullscreen")] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"nonfullscreen")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"nonfullscreen")] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    //autoLayout fullScreenBtn
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(0);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(40);
        
    }];
    
    //timeLabel
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.timeLabel];
    //autoLayout timeLabel
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    
    [self bringSubviewToFront:self.bottomView];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.showsTouchWhenHighlighted = YES;
    [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"close")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"close")] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:YGFVideoSrcName(@"close")] ?: [UIImage imageNamed:YGFVideoFrameworkSrcName(@"close")] forState:UIControlStateSelected];
    _closeBtn.layer.cornerRadius = 30/2;
    [self addSubview:_closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self).with.offset(5);
        make.width.mas_equalTo(30);
    }];
    
    // 单击的 Recognizer
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTap.numberOfTapsRequired = 1; // 单击
    [self addGestureRecognizer:singleTap];
    
    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleTap.numberOfTapsRequired = 2; // 双击
    [self addGestureRecognizer:doubleTap];
    
    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
    [self initTimer];
}

- (void)updateSystemVolumeValue:(UISlider *)slider {
    systemSlider.value = slider.value;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

#pragma mark
#pragma mark - fullScreenAction---------
- (void)fullScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    //用通知的形式把点击全屏的时间发送到app的任何地方，方便处理其他逻辑
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fullScreenBtnClickNotice" object:sender];
}

- (void)colseTheVideo:(UIButton *)sender {
    [self.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeTheVideo" object:sender];
}

- (double)duration {
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds([[playerItem asset] duration]);
    } else {
        return 0.f;
    }
}

- (double)currentTime {
    return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time {
    [[self player] seekToTime:CMTimeMakeWithSeconds(time, 1)];
}

#pragma mark - PlayOrPause---------
- (void)PlayOrPause:(UIButton *)sender{
    if (self.durationTimer == nil) {
        self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
    }
    sender.selected = !sender.selected;
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
    
    //    CMTime time = [self.player currentTime];
}

#pragma mark - 单击手势方法---------
- (void)handleSingleTap {
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            self.bottomView.alpha = 1.0;
            self.closeBtn.alpha = 1.0;
        } else {
            self.bottomView.alpha = 0.0;
            self.closeBtn.alpha = 0.0;
        }
    } completion:^(BOOL finish){
    }];
}

#pragma mark - 双击手势方法--------
- (void)handleDoubleTap {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    if (self.player.rate != 1.f) {
        if ([self currentTime] == self.duration)
            [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
}

#pragma mark - 设置播放的视频-------
- (void)setVideoURLStr:(NSString *)videoURLStr {
    _videoURLStr = videoURLStr;
    if (self.currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [self.currentItem removeObserver:self forKeyPath:@"status"];
        //        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    self.currentItem = [self getPlayItemWithURLString:videoURLStr];
    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    WEAKSELF
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.progressSlider setValue:0.0 animated:YES];
        weakSelf.playOrPauseBtn.selected = NO;
    }];
    //片段播放完成
    [self onPlayerNextVideoSingle];
}

#pragma mark - 播放进度----------
- (void)updateProgress:(UISlider *)slider {
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, 1)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    /* AVPlayerItem "status" property value observer. */
    if (context == PlayViewStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status){
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                if (CMTimeGetSeconds(self.player.currentItem.duration)) {
                    self.progressSlider.maximumValue = self.videoTotalTime;
                }
                [self initTimer];
                if (self.durationTimer == nil) {
                    self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
                }
                //5s dismiss bottomView
                if (self.autoDismissTimer == nil) {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }
            }
                break;
            case AVPlayerStatusFailed:
            {
                
            }
                break;
        }
    }
}

#pragma mark ---finishedPlay---------
- (void)finishedPlay:(NSTimer *)timer {
    if (self.currentTime == self.duration&&self.player.rate==.0f) {
        self.playOrPauseBtn.selected = YES;
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

#pragma mark ----autoDismissBottomView------
- (void)autoDismissBottomView:(NSTimer *)timer {
    if (self.player.rate==.0f&&self.currentTime != self.duration) {//暂停状态
        
    }else if(self.player.rate == 1.0f){
        if (self.bottomView.alpha == 1.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.bottomView.alpha = 0.0;
                self.closeBtn.alpha = 0.0;
            } completion:^(BOOL finish){
            }];
        }
    }
}

#pragma  maik - 定时器-------
- (void)initTimer {
    double interval = .1f;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = self.videoTotalTime;
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
        interval = 0.5f * duration / width;
    }
    NSLog(@"interva === %f",interval);
    WEAKSELF
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)  queue:NULL /* If you pass NULL, the main queue is used. */ usingBlock:^(CMTime time){
        [self syncScrubber];
    }];
}

- (void)syncScrubber {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        self.progressSlider.minimumValue = 0.0;
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:time],[self convertTime:self.videoTotalTime]];
        [self settingTime:[self convertTime:time]];
        [self.progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

#pragma mark --设置时间--------
- (void)settingTime:(NSString *)playingTime {
    NSArray *playingArray = [playingTime componentsSeparatedByString:@":"];
    self.playingTime = 0;
    if ([playingArray count] == 3) {
        self.playingTime = [playingArray[0]integerValue] * 60 * 60 + [playingArray[1]integerValue] * 60 + [playingArray[2]integerValue];
    } else {
        self.playingTime = [playingArray[0]integerValue] * 60 + [playingArray[1]integerValue];
    }
}

- (CMTime)playerItemDuration {
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (NSString *)convertTime:(CGFloat)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *newTime = [[self dateFormatter] stringFromDate:d];
    return newTime;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in event.allTouches) {
        self.firstPoint = [touch locationInView:self];
        
    }
    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    volumeSlider.value = systemSlider.value;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in event.allTouches) {
        self.secondPoint = [touch locationInView:self];
    }
    systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/500.0;
    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    volumeSlider.value = systemSlider.value;
    self.firstPoint = self.secondPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.firstPoint = self.secondPoint = CGPointZero;
}

- (void)dealloc {
    [self.player pause];
    self.autoDismissTimer = nil;
    self.durationTimer = nil;
    self.player = nil;
    [self.currentItem removeObserver:self forKeyPath:@"status"];
}

#pragma mark --控制下载
//判断M3U8文件是否存在
- (void)findM3U8File {
    if ([self fileExistsAtPath]) {
        [self setVideoURLStr:kDownloadVideoUrl];
        [self.player play];
    } else {
        //不存在就去下载
        [self onChangeDownloadState];
    }
}

- (BOOL)fileExistsAtPath {
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:kDownloadVideoId];
    savePath = [savePath stringByAppendingPathComponent:kDownloadVideoUrl];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if([fileManager fileExistsAtPath:savePath isDirectory:&isDir]){
        return YES;
    } else {
        return NO;
    }
}

- (void)setStateLabelContent {
    NSString *videoDownloadState = @"";
    switch (self.videoDownload.downloadState) {
        case DownloadVideoStateWating:
        {
            videoDownloadState = @"等待中";
            if (self.videoDownloadStateWating) {
                self.videoDownloadStateWating(videoDownloadState);
            }
            NSLog(@"videoDownloadState---------%@", videoDownloadState);
        }
            break;
        case DownloadVideoStateDownloading:
        {
            videoDownloadState = @"下载中";
            if (self.videoDownloadStateDownloading) {
                self.videoDownloadStateDownloading(videoDownloadState);
            }
             NSLog(@"videoDownloadState---------%@", videoDownloadState);
        }
            break;
        case DownloadVideoStatePausing:
        {
            videoDownloadState = @"暂停中";
            if (self.videoDownloadStatePausing) {
                self.videoDownloadStatePausing(videoDownloadState);
            }
             NSLog(@"videoDownloadState---------%@", videoDownloadState);
        }
            break;
        case DownloadVideoStateFail:
        {
            videoDownloadState = @"下载失败";
            if (self.videoDownloadStateFail) {
                self.videoDownloadStateFail(videoDownloadState);
            }
             NSLog(@"videoDownloadState---------%@", videoDownloadState);
        }
            break;
        case DownloadVideoStateFinish:
        {
            videoDownloadState = @"下载完成";
            if (self.videoDownloadStateFinish) {
                self.videoDownloadStateFinish(videoDownloadState);
            }
             NSLog(@"videoDownloadState---------%@", videoDownloadState);
        }
            break;
        default:
            break;
    }
}

- (void)onChangeDownloadState {
    //下载->暂停；未下载->下载
    if (![self fileExistsAtPath]) {
        if (!_videoDownload) {
            _videoDownload = [[YGFM3U8VideoDownload alloc] initWithVideoId:kDownloadVideoId VideoUrl:self.m3u8_url];
            _videoDownload.delegate = self;
        }
        if (_videoDownload.downloadState!=DownloadVideoStateFinish) {
            [_videoDownload changeDownloadVideoState];
            [self setStateLabelContent];
        }
    }
}

- (void)onDeleteDownloadVideo {
    if (!_videoDownload) {
        _videoDownload = [[YGFM3U8VideoDownload alloc] initWithVideoId:kDownloadVideoId VideoUrl:self.m3u8_url];
        _videoDownload.delegate = self;
    }
    [_videoDownload deleteDownloadVideo];
    [self setStateLabelContent];
}

- (void)onPlayerNextVideoSingle {
    /**
     * @guangfu yang 16-2-27 16:01
     *
     * 视频继续播放和继续下载片段
     **/
    if (self.playingTime == self.videoTotalTime) {
        //整个视频播放完毕了
        [self onDeleteDownloadVideo];
        return;
    }
    [self setVideoURLStr:kDownloadVideoUrl];
    [self.player play];
    //继续下载片段
    if (!self.videoDownloadFinished) {
        [self onChangeDownloadState];
    }
}


#pragma mark --YGFM3U8VideoDownloadDelegate------
- (void)M3U8VideoDownloadParseFinish:(NSMutableArray *)segmentTimeArray {
    self.videoSegmentArray = segmentTimeArray;
    for (NSString *segment in segmentTimeArray) {
        self.videoTotalTime += [segment integerValue];
    }
}

- (void)M3U8VideoDownloadFail {
    if (self.videoDownloadFail) {
        self.videoDownloadFail(@"下载失败啦");
    }
}

- (void)M3U8VideoDownloadFinish {
    self.videoDownloadFinished = YES;
    if (self.videoDownloadFinish) {
        self.videoDownloadFinish(@"下载完成可以播放啦");
    }
}

- (void)M3U8VideoDownloadParseFail {
    //回传到主线程显示
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.videoDownloadParseFail) {
            self.videoDownloadParseFail(@"解析失败啦！换个视频地址试试");
        }
    });
}

- (void)M3U8VideoDownloadProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
       // NSString *progressStr = [NSString stringWithFormat:@"%.1f%%",progress];
//        if ([self.downloadProgressLabel.text isEqualToString:@"100.0%"]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"M3U8VideoDownloadFinish" object:nil];
//        }
    });
}

- (void)M3U8VideoSingleDownloadFinishStartPlay {
    ++self.videoDownloadCount;
    if (self.videoDownloadCount == 1) {
        [self setVideoURLStr:kDownloadVideoUrl];
        [self.player play];
    }
    if (self.videoDownloadCount % 2 != 0) {
        if (!self.videoDownloadFinished) {
            [self onChangeDownloadState];//一次下载2个片段
        }
    }
}

@end
