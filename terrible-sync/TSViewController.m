//
//  TSViewController.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import "TSViewController.h"

#define TS_NUM_BEATS_VIEWS 3
#define TS_MIN_BPM 60.0f
#define TS_MAX_BPM 480.0f

@interface TSViewController ()
{
    NSTimeInterval dtmLastTap;
}

@property (nonatomic, strong) UIButton *btnTap;
@property (nonatomic, strong) UIView *vBeat;

@property (nonatomic, strong) NSTimer *tmrBeat;

- (void)tap;
- (void)stopBeat;
- (void)startBeatWithDuration: (NSTimeInterval)duration;
- (void)beat;

@end

@implementation TSViewController

- (id)init
{
    if (self = [super init]) {
        dtmLastTap = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // beats views
    self.vBeat = [[UIView alloc] init];
    _vBeat.backgroundColor = [UIColor whiteColor];
    _vBeat.clipsToBounds = YES;
    [self.view addSubview:_vBeat];
    
    // the button
    self.btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnTap addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    _btnTap.clipsToBounds = YES;
    _btnTap.backgroundColor = [UIColor blackColor];
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
    _vBeat.frame = _btnTap.frame;
    _vBeat.layer.cornerRadius = _btnTap.layer.cornerRadius;
}


#pragma mark internal

- (void)tap
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sinceLastTap = now - dtmLastTap;
    CGFloat bpm = 60.0f / sinceLastTap;
    if (bpm >= TS_MIN_BPM && bpm <= TS_MAX_BPM) {
        [self startBeatWithDuration:sinceLastTap];
    }
    
    dtmLastTap = now;
}

- (void)stopBeat
{
    if (_tmrBeat) {
        [_tmrBeat invalidate];
        _tmrBeat = nil;
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
    _vBeat.transform = CGAffineTransformIdentity;
    _vBeat.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.1f animations:^{
        _vBeat.transform = CGAffineTransformIdentity;
    }];
}

@end
