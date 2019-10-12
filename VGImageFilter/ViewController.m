//
//  ViewController.m
//  VGImageFilter
//
//  Created by 周智伟 on 2019/6/18.
//  Copyright © 2019 vege. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VGAlphaBackgroundVideoFilter.h"
#import "VGImageView.h"
#import "VGMovie.h"

@interface ViewController ()
{
    AVPlayer *avPlayer;
    __weak IBOutlet UISlider *silder;
    CGFloat progress;
    
    VGMovie *movie;
    VGAlphaBackgroundVideoFilter *filter;
    VGImageView *moviePlayerView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"image"];
    [self.view addSubview:imageView];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"333" ofType:@"mp4"];
    
    movie = [[VGMovie alloc]initWithPath:path];
    moviePlayerView = [[VGImageView alloc]initWithFrame:CGRectMake(40, 40, 300, 300)];
    [self.view addSubview:moviePlayerView];
    
    filter = [[VGAlphaBackgroundVideoFilter alloc]initWithColor:VGAlphaBackgroundColorBlack];
    
    [movie addTarget:filter];
    
    [filter addTarget:moviePlayerView];
    
    [self.view bringSubviewToFront:silder];
}

- (void)playerAtProgress:(CGFloat)progress{
    CMTime time = CMTimeMake(movie.duration.value *progress, movie.duration.timescale);
    
    [movie seekToTime:time];
}

#pragma mark - Event
- (void)displayEvent{
    [self playerAtProgress:progress];
    
    if (progress > 1.0) {
        progress = 0.0;
    }
}

- (IBAction)sliderEvent:(UISlider *)sender {
    [self playerAtProgress:sender.value];
}
@end
