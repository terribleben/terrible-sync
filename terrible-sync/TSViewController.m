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
#define TS_MIN_BPM 40.0f
#define TS_MAX_BPM 999.0f

NSString * const kTSLastTempoUserDefaultsKey = @"TSLastTempoUserDefaultsKey";

@interface TSViewController ()
{
    NSTimeInterval dtmLastTap;
    NSTimeInterval dtmLastLastTap;
}

@property (nonatomic, strong) UIButton *btnTap;
@property (nonatomic, strong) UILabel *lblBpm;
@property (nonatomic, strong) UIView *vHitArea;
@property (nonatomic, strong) UIView *vBeat;

@property (nonatomic, strong) UIButton *btnTempoUp;
@property (nonatomic, strong) UIButton *btnTempoDown;

@property (nonatomic, strong) NSTimer *tmrBeat;
@property (atomic, strong) NSNumber *currentBeatDuration;

- (void)onTapBeat;
- (void)onTapTempoUp;
- (void)onTapTempoDown;

- (void)stopBeat;
- (void)scheduleNextBeat;
- (void)beat;

- (void)updateCurrentBPM:(float)bpm syncImmediately: (BOOL)syncImmediately;

@end

@implementation TSViewController

- (id)init
{
    if (self = [super init]) {
        dtmLastTap = 0;
        dtmLastLastTap = 0;
        self.currentBeatDuration = @(0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // beat animation view
    self.vBeat = [[UIView alloc] init];
    _vBeat.backgroundColor = [UIColor whiteColor];
    _vBeat.clipsToBounds = YES;
    [self.view addSubview:_vBeat];
    
    // the button
    self.btnTap = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    // hit area view-- because the animated button has trouble detecting hits accurately
    self.vHitArea = [[UIView alloc] init];
    _vHitArea.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_vHitArea];
    
    UITapGestureRecognizer *grTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBeat)];
    [_vHitArea addGestureRecognizer:grTap];
    
    // up button
    self.btnTempoUp = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnTempoUp setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    _btnTempoUp.frame = CGRectMake(0, 0, 42.0f, 24.0f);
    [_btnTempoUp addTarget:self action:@selector(onTapTempoUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnTempoUp];
    
    // down button
    self.btnTempoDown = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnTempoDown setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    _btnTempoDown.frame = _btnTempoUp.frame;
    [_btnTempoDown addTarget:self action:@selector(onTapTempoDown) forControlEvents:UIControlEventTouchUpInside];
    _btnTempoDown.transform = CGAffineTransformMakeScale(1.0f, -1.0f);
    [self.view addSubview:_btnTempoDown];
    
    // fire up the audio
    [TSPulseGen sharedInstance];
    
    // launch beat timer
    NSNumber *lastTempo = [[NSUserDefaults standardUserDefaults] objectForKey:kTSLastTempoUserDefaultsKey];
    if (lastTempo) {
        [self updateCurrentBPM:lastTempo.floatValue syncImmediately:YES];
    } else {
        [self updateCurrentBPM:120.0f syncImmediately:YES];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _btnTap.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.view.bounds.size.height * 0.4f);
    
    _btnTempoUp.center = CGPointMake(_btnTap.center.x, CGRectGetMinY(_btnTap.frame) - 48.0f);
    _btnTempoDown.center = CGPointMake(_btnTap.center.x, CGRectGetMaxY(_btnTap.frame) + 48.0f);
    
    _lblBpm.frame = CGRectMake(0, 0, _btnTap.frame.size.width, 12.0f);
    _lblBpm.center = CGPointMake(_btnTap.center.x, _btnTap.center.y + 20.0f);
    
    _vBeat.frame = _btnTap.frame;
    _vBeat.layer.cornerRadius = _btnTap.layer.cornerRadius;
    
    _vHitArea.frame = _btnTap.frame;
}


#pragma mark internal

- (void)onTapBeat
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sinceLastTap = now - dtmLastTap;
    NSTimeInterval betweenPreviousTaps = dtmLastTap - dtmLastLastTap;
    
    CGFloat bpmLast = (sinceLastTap > 0) ? (60.0f / sinceLastTap) : 0;
    CGFloat bpmPrevious = (betweenPreviousTaps > 0) ? (60.0f / betweenPreviousTaps) : 0;
    
    CGFloat bpmAverage = 0;
    if (bpmPrevious >= TS_MIN_BPM && bpmLast >= TS_MIN_BPM)
        bpmAverage = (bpmPrevious + bpmLast) * 0.5f;
    else
        bpmAverage = bpmLast;
    
    [self updateCurrentBPM:bpmAverage syncImmediately:YES];
    
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

- (void)scheduleNextBeat
{
    [self stopBeat];
    
    // don't use a repeating timer because the duration could change between timer fires.
    _tmrBeat = [NSTimer scheduledTimerWithTimeInterval:self.currentBeatDuration.floatValue target:self selector:@selector(beat) userInfo:nil repeats:NO];
}

- (void)beat
{
    // continue beating
    [self scheduleNextBeat];
    
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

- (void)onTapTempoUp
{
    float bpmCurrent = 60.0f / self.currentBeatDuration.floatValue;
    [self updateCurrentBPM:(bpmCurrent + 1.0) syncImmediately:NO];
}

- (void)onTapTempoDown
{
    float bpmCurrent = 60.0f / self.currentBeatDuration.floatValue;
    [self updateCurrentBPM:(bpmCurrent - 1.0) syncImmediately:NO];
}

- (void)updateCurrentBPM:(float)bpm syncImmediately:(BOOL)syncImmediately
{
    if (bpm >= TS_MIN_BPM && bpm <= TS_MAX_BPM) {
        // round to nearest half-bpm (better for programming the tempo into other objects)
        float approxBpm = roundf(bpm * 2.0f) * 0.5f;
        
        self.currentBeatDuration = @(60.0f / approxBpm);
        [_btnTap setTitle:[NSString stringWithFormat:@"%.1f", approxBpm] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@(approxBpm) forKey:kTSLastTempoUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (syncImmediately) {
            // schedule next beat immediately (to sync with tap)
            [self scheduleNextBeat];
        }
    }
}

@end
