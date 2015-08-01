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
#import "TSDancingButton.h"

NSString * const kTSLastTempoUserDefaultsKey = @"TSLastTempoUserDefaultsKey";

@interface TSViewController () <TSClockDelegate>

@property (nonatomic, strong) TSClock *clock;

@property (nonatomic, strong) TSDancingButton *btnTap;

@property (nonatomic, strong) UIButton *btnTempoUp;
@property (nonatomic, strong) UIButton *btnTempoDown;

@property (nonatomic, strong) TSDancingButton *btnConfused;
@property (nonatomic, strong) TSDancingButton *btnAlarmed;
@property (nonatomic, strong) TSDancingButton *btnMystery;

- (void)onTapBeat;
- (void)onTapTempoUp;
- (void)onTapTempoDown;
- (void)onTapConfused;
- (void)onTapAlarmed;
- (void)onTapMystery;

- (void)updateUI;

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
    
    // the big enormous button
    self.btnTap = [[TSDancingButton alloc] initWithFrame:CGRectMake(0, 0, 192.0f, 192.0f)];
    _btnTap.subtitle = @"BPM";
    [self.view addSubview:_btnTap];
    
    UITapGestureRecognizer *tapButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBeat)];
    [_btnTap addGestureRecognizer:tapButton];
    
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
    self.btnConfused = [[TSDancingButton alloc] initWithFrame:CGRectMake(0, 0, 66.0f, 66.0f)];
    [_btnConfused.internalButton setTitle:@"?" forState:UIControlStateNormal];
    [self.view addSubview:_btnConfused];
    
    UITapGestureRecognizer *tapConfused = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapConfused)];
    [_btnConfused addGestureRecognizer:tapConfused];
    
    // alarmed button
    self.btnAlarmed = [[TSDancingButton alloc] initWithFrame:_btnConfused.frame];
    [_btnAlarmed.internalButton setTitle:@"!" forState:UIControlStateNormal];
    [self.view addSubview:_btnAlarmed];
    
    UITapGestureRecognizer *tapAlarmed = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAlarmed)];
    [_btnAlarmed addGestureRecognizer:tapAlarmed];
    
    // mystery button
    self.btnMystery = [[TSDancingButton alloc] initWithFrame:_btnConfused.frame];
    [_btnMystery.internalButton setTitle:@"🔥" forState:UIControlStateNormal];
    [self.view addSubview:_btnMystery];
    
    UITapGestureRecognizer *tapMystery = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMystery)];
    [_btnMystery addGestureRecognizer:tapMystery];
    
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
    
    _btnConfused.center = CGPointMake(self.view.bounds.size.width * 0.22f, self.view.bounds.size.height - 64.0f);
    _btnAlarmed.center = CGPointMake(self.view.bounds.size.width * 0.5f, _btnConfused.center.y);
    _btnMystery.center = CGPointMake(self.view.bounds.size.width * 0.78f, _btnConfused.center.y);
}


#pragma mark delegate

- (void)clockDidBeat:(TSClock *)clock
{
    // generate a pulse
    [[TSPulseGen sharedInstance] pulse];
    
    // animate
    [_btnTap bounce];
    
    if (clock.isConfused) {
        [_btnConfused bounce];
    }
    if (clock.isAlarmed) {
        [_btnAlarmed bounce];
    }
    if (clock.isEnigmatic) {
        [_btnMystery bounce];
        [self updateUI];
    }
}

- (void)clock:(TSClock *)clock didUpdateTempo:(float)bpm
{
    [self updateUI];
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

- (void)onTapAlarmed
{
    _clock.isAlarmed = !_clock.isAlarmed;
    [self updateUI];
}

- (void)onTapConfused
{
    _clock.isConfused = !_clock.isConfused;
    [self updateUI];
}

- (void)onTapMystery
{
    _clock.isEnigmatic = !_clock.isEnigmatic;
    [self updateUI];
}

- (void)updateUI
{
    NSMutableString *status;
    
    if (_clock.isEnigmatic) {
        // what is this help me
        unsigned int val = 0x1f330 + (rand() % (16 * 20));
        status = [[NSMutableString alloc] initWithBytes:&val length:sizeof(val) encoding:NSUTF32LittleEndianStringEncoding];
    } else {
        status = [NSMutableString stringWithFormat:@"%.1f", _clock.currentBpm];
    }
    if (_clock.isConfused) {
        [status appendString:@"?"];
    }
    if (_clock.isAlarmed) {
        [status appendString:@"!"];
    }
    
    [_btnTap.internalButton setTitle:status forState:UIControlStateNormal];
}

@end
