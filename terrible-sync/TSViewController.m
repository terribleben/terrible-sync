//
//  TSViewController.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import "TSViewController.h"
#import "TSPulseGen.h"

#define TS_NUM_BEATS_VIEWS 3
#define TS_MIN_BPM 60.0f
#define TS_MAX_BPM 480.0f

@interface TSViewController ()
{
    NSTimeInterval dtmLastTap;
    NSTimeInterval dtmLastLastTap;
}

@property (nonatomic, strong) UIButton *btnTap;
@property (nonatomic, strong) UILabel *lblBpm;
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
    
    // bpm label
    self.lblBpm = [[UILabel alloc] init];
    _lblBpm.font = [UIFont boldSystemFontOfSize:10.0f];
    _lblBpm.textColor = [UIColor lightGrayColor];
    _lblBpm.textAlignment = NSTextAlignmentCenter;
    _lblBpm.text = @"BPM";
    [self.view addSubview:_lblBpm];
    
    // fire up the audio
    [TSPulseGen sharedInstance];
    
    // launch beat timer
    [self startBeatWithDuration:(60.0f / 120.0f)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _btnTap.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.view.bounds.size.height * 0.4f);
    
    _lblBpm.frame = CGRectMake(0, 0, _btnTap.frame.size.width, 12.0f);
    _lblBpm.center = CGPointMake(_btnTap.center.x, _btnTap.center.y + 20.0f);
    
    _vBeat.frame = _btnTap.frame;
    _vBeat.layer.cornerRadius = _btnTap.layer.cornerRadius;
}


#pragma mark internal

- (void)tap
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sinceLastTap = now - dtmLastTap;
    NSTimeInterval betweenPreviousTaps = dtmLastTap - dtmLastLastTap;
    
    CGFloat bpmLast = 60.0f / sinceLastTap;
    CGFloat bpmPrevious = 60.0f / betweenPreviousTaps;
    
    CGFloat bpmAverage = 0;
    if (bpmPrevious >= TS_MIN_BPM && bpmLast >= TS_MIN_BPM)
        bpmAverage = (bpmPrevious + bpmLast) * 0.5f;
    else
        bpmAverage = bpmLast;
    
    if (bpmAverage >= TS_MIN_BPM && bpmAverage <= TS_MAX_BPM) {
        [self startBeatWithDuration:sinceLastTap];
    }
    
    dtmLastLastTap = dtmLastTap;
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
    // generate a pulse
    [[TSPulseGen sharedInstance] pulse];
    
    // animate
    _vBeat.transform = CGAffineTransformIdentity;
    _btnTap.transform = CGAffineTransformIdentity;
    
    _vBeat.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    _btnTap.transform = CGAffineTransformMakeScale(0.96f, 0.96f);
    
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _vBeat.transform = CGAffineTransformIdentity;
        _btnTap.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
