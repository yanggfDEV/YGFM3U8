//
//  YGFM3U8SegmentDownload.m
//  YGFHLS-M3U8
//
//  Created by guangfu yang on 16/2/26.
//  Copyright © 2016年 yangguangfu. All rights reserved.
//

#import "YGFM3U8SegmentDownload.h"
#import "ASIHTTPRequest.h"
#import "ASIProgressDelegate.h"

@interface YGFM3U8SegmentDownload ()<ASIProgressDelegate,ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *tmpFilePath;

@property (nonatomic, strong) ASIHTTPRequest *request;

@end

@implementation YGFM3U8SegmentDownload

- (id)initWithUrl:(NSString *)url FilePath:(NSString *)path FileName:(NSString *)name {
    if (self = [super init]) {
        self.filePath = path;
        self.fileName = kTempDownloadVideo;
        self.fileUrl = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        //这里针对不同的下载方法还需要改动下
        self.tmpFilePath = [NSString stringWithString:[savePath stringByAppendingPathComponent:[self.fileName stringByAppendingString:kTestDownloadingFileSuffix]]];
        BOOL isDir = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:savePath isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)start {
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *savePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
    
    NSURL *URL = [NSURL URLWithString:[self.fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    self.request = [ASIHTTPRequest requestWithURL:URL];
    [self.request setTemporaryFileDownloadPath:self.tmpFilePath];
    [self.request setDownloadDestinationPath:[savePath stringByAppendingPathComponent:self.fileName]];
    [self.request setDelegate:self];
    [self.request setDownloadProgressDelegate:self];
    self.request.allowResumeForFileDownloads = YES;
    [self.request setNumberOfTimesToRetryOnTimeout:2];
    [self.request startAsynchronous];
}

- (void)pause {
    self.request.delegate = nil;
    [self.request cancelAuthentication];
}

- (void)cancel {
    self.request.delegate = nil;
    [self.request cancelAuthentication];
}

#pragma mark --- ASIHTTPRequestDelegate ---
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"download segment %@ success",self.fileName);
    NSRange rang = {2,1};
    NSInteger listIndex = [[self.fileName substringWithRange:rang] integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadFinished:listIndex:)]) {
        [self.delegate M3U8SegmentDownloadFinished:self listIndex:listIndex];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentSingleDownloadFinished:)]) {
        [self.delegate M3U8SegmentSingleDownloadFinished:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"download segment %@ fail",self.fileName);
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadFailed:)]) {
        [self.delegate M3U8SegmentDownloadFailed:self];
    }
}



#pragma mark --- ASIProgressDelegate ---
- (void)setProgress:(float)newProgress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8SegmentDownloadProgress:)]) {
        [self.delegate M3U8SegmentDownloadProgress:newProgress];
    }
    
    //大于0就开始播放吧
    if (self.delegate && [self.delegate respondsToSelector:@selector(M3U8ProgressStartPlayer)]) {
        [self.delegate M3U8ProgressStartPlayer];
    }
}




@end
