//
//  YGFM3U8ViewController.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFM3U8ViewController.h"
#import "YGFHLSM3U8Player.h"

@interface YGFM3U8ViewController ()

@property (nonatomic, strong) YGFHLSM3U8Player *ygfHLSM3U8Player;

@end

@implementation YGFM3U8ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *m3u8_url = @"http://flv2.bn.netease.com/videolib3/1602/25/ceCDU5963/SD/movie_index.m3u8";
//    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:m3u8_url]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:[playerViewController moviePlayer]];

//    [self.view addSubview:playerViewController.view];
//    [playerViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    
    // play movie
//    MPMoviePlayerController *player = [playerViewController moviePlayer];
//    player.controlStyle = MPMovieControlStyleFullscreen;
//    player.shouldAutoplay = YES;
//    player.repeatMode = MPMovieRepeatModeOne;
//    [player setFullscreen:YES animated:YES];
//    player.scalingMode = MPMovieScalingModeAspectFit;
//    [player play];
    
    
    self.ygfHLSM3U8Player = [[YGFHLSM3U8Player alloc]initWithFrame:self.view.bounds videoURLStr:m3u8_url];
    [self.view addSubview:self.ygfHLSM3U8Player];
    [self.ygfHLSM3U8Player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
//    [self.ygfHLSM3U8Player.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
