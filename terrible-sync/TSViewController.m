//
//  TSViewController.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import "TSViewController.h"

@interface TSViewController ()

@property (nonatomic, strong) UIButton *btnTap;
@property (nonatomic, strong) NSTimer *tmrBeat;

- (void)stopBeat;
- (void)startBeatWithDuration: (NSTimeInterval)duration;
- (void)beat;

@end

@implementation TSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // the button
    self.btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnTap.clipsToBounds = YES;
    _btnTap.frame = CGRectMake(0, 0, 192.0f, 192.0f);
    _btnTap.layer.borderWidth = 6.0f / [UIScreen mainScreen].scale;
    _btnTap.layer.borderColor = [UIColor redColor].CGColor;
    _btnTap.layer.cornerRadius = 192.0f * 0.5f;
    _btnTap.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [_btnTap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_btnTap];
    
    [self startBeatWithDuration:(60.0f / 120.0f)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _btnTap.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.view.bounds.size.height * 0.4f);
}


#pragma mark internal

- (void)stopBeat
{
    if (_tmrBeat) {
        _tmrBeat = nil;
        [_tmrBeat invalidate];
    }
}

- (void)startBeatWithDuration:(NSTimeInterval)duration
{
    [self stopBeat];
    
    _tmrBeat = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(beat) userInfo:nil repeats:YES];
    [_btnTap setTitle:[NSString stringWithFormat:@"%.1f", 60.0f * (1.0f / duration)] forState:UIControlStateNormal];
}

- (void)beat
{
    NSLog(@"beat");
}

@end
