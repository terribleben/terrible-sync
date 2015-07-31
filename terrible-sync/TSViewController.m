//
//  TSViewController.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import "TSViewController.h"
#import "TSPulseGen.h"
#import "TSClock.h"

NSString * const kTSLastTempoUserDefaultsKey = @"TSLastTempoUserDefaultsKey";

@interface TSViewController () <TSClockDelegate>

@property (nonatomic, strong) TSClock *clock;

@property (nonatomic, strong) UIButton *btnTap;
@property (nonatomic, strong) UILabel *lblBpm;
@property (nonatomic, strong) UIView *vHitArea;
@property (nonatomic, strong) UIView *vBeat;

@property (nonatomic, strong) UIButton *btnTempoUp;
@property (nonatomic, strong) UIButton *btnTempoDown;

@property (nonatomic, strong) UIButton *btnConfused;
@property (nonatomic, strong) UIButton *btnAlarmed;

- (void)onTapBeat;
- (void)onTapTempoUp;
- (void)onTapTempoDown;

@end

@implementation TSViewController

- (id)init
{
    if (self = [super init]) {
        self.clock = [[TSClock alloc] init];
        _clock.delegate = self;
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
    
    // the big enormous button
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
    
    // confused button
    self.btnConfused = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnConfused.frame = CGRectMake(0, 0, 66.0f, 66.5f);
    [_btnConfused setImage:[UIImage imageNamed:@"btn_question"] forState:UIControlStateNormal];
    [self.view addSubview:_btnConfused];
    
    // alarmed button
    self.btnAlarmed = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAlarmed.frame = CGRectMake(0, 0, 66.0f, 66.5f);
    [_btnAlarmed setImage:[UIImage imageNamed:@"btn_bang"] forState:UIControlStateNormal];
    [self.view addSubview:_btnAlarmed];
    
    // fire up the audio
    [TSPulseGen sharedInstance];
    
    // launch beat timer
    NSNumber *lastTempo = [[NSUserDefaults standardUserDefaults] objectForKey:kTSLastTempoUserDefaultsKey];
    if (lastTempo) {
        [_clock updateCurrentBPM:lastTempo.floatValue syncImmediately:YES];
    } else {
        [_clock updateCurrentBPM:120.0f syncImmediately:YES];
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
    
    _btnConfused.center = CGPointMake(self.view.bounds.size.width * 0.66f, self.view.bounds.size.height - 64.0f);
    _btnAlarmed.center = CGPointMake(self.view.bounds.size.width * 0.33f, _btnConfused.center.y);
}


#pragma mark delegate

- (void)clockDidBeat:(TSClock *)clock
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

- (void)clock:(TSClock *)clock didUpdateTempo:(float)bpm
{
    [_btnTap setTitle:[NSString stringWithFormat:@"%.1f", bpm] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@(bpm) forKey:kTSLastTempoUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark internal

- (void)onTapBeat
{
    [_clock onTap];
}

- (void)onTapTempoUp
{
    [_clock increaseCurrentBPM];
}

- (void)onTapTempoDown
{
    [_clock decreaseCurrentBPM];
}

@end
