//
//  VGMovieDataReader.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/7/15.
//  Copyright © 2019 vege. All rights reserved.
//

#import "VGMovieDataReader.h"
#import "VGProgram.h"

# define ONE_FRAME_DURATION 0.03
static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface VGMovieDataReader()<AVPlayerItemOutputPullDelegate>
{
    AVPlayer * _player;
    dispatch_queue_t _myVideoOutputQueue;
    id _notificationToken;
    
    CGFloat _videoRotation;
    CGSize  _videoPresentationSize;
    
    NSURL *_videoUrl;
    
    BOOL loadFinish;
}
@property AVPlayerItemVideoOutput *videoOutput;
@end

@implementation VGMovieDataReader
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _videoUrl = [[NSURL alloc]initFileURLWithPath:path];
        
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        self.videoOutput = [[AVPlayerItemVideoOutput alloc]initWithPixelBufferAttributes:pixBuffAttributes];
        _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
        [[self videoOutput]setDelegate:self queue:_myVideoOutputQueue];
        if (_videoUrl == nil) {
            NSLog(@"Error: video path not founded");
        }else{
            [self loadPlayerFrom:_videoUrl];
            [self addPlayerStatusObserve];
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:AVPlayerItemStatusContext];
}

#pragma mark - Public
- (void)seekToTime:(CMTime)time{
    if (!loadFinish) {
        return;
    }
    if (time.timescale == 0) {
        return;
    }
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self pixelBufferAtTime:_player.currentItem.currentTime];
}

#pragma mark - Private
- (void)loadPlayerFrom:(NSURL *)url{
    
    _player = [[AVPlayer alloc]init];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVAsset *asset = [item asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (tracks.count > 0) {
            AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
            NSString *transformKey = @"preferredTransform";
            [videoTrack loadValuesAsynchronouslyForKeys:@[transformKey] completionHandler:^{
                if ([videoTrack statusOfValueForKey:transformKey error:nil] == AVKeyValueStatusLoaded) {
                    
                    //获取视频默认旋转信息
                    CGAffineTransform preferredTransform = [videoTrack preferredTransform];
                    self->_videoRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
                    
                    [self addNotificationForPlayerItem:item];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [item addOutput:self.videoOutput];
                        [self->_player replaceCurrentItemWithPlayerItem:item];
                    });
                }
            }];
        }
    }];
}

- (void)addNotificationForPlayerItem:(AVPlayerItem *)item{
    if (_notificationToken) {
        _notificationToken = nil;
    }
    
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _notificationToken = [[NSNotificationCenter defaultCenter]addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[self->_player currentItem]seekToTime:kCMTimeZero];
    }];
}

- (void)addPlayerStatusObserve{
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
}

- (void)pixelBufferAtTime:(CMTime)time{
    if ([[self videoOutput] hasNewPixelBufferForItemTime:time]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:time itemTimeForDisplay:NULL];
        if ([self.delegate respondsToSelector:@selector(movieHasUpdatedPixelBuffer:)]) {
            [self.delegate movieHasUpdatedPixelBuffer:pixelBuffer];
        }
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == AVPlayerItemStatusContext) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                loadFinish = YES;
                _videoPresentationSize = [[_player currentItem] presentationSize];
                _duration = _player.currentItem.duration;
                if ([self.delegate respondsToSelector:@selector(movieLoadSuccessWithRotation:presentationSize:)]) {
                    [self.delegate movieLoadSuccessWithRotation:_videoRotation presentationSize:_videoPresentationSize];
                }
                break;
            case AVPlayerStatusFailed:
                loadFinish = YES;
                if ([self.delegate respondsToSelector:@selector(movieLoadFail)]) {
                    [self.delegate movieLoadFail];
                }
                break;
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
