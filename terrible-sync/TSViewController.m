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
#import "TSRotaryButton.h"
#import "UIView+TS.h"

NSString * const kTSLastTempoUserDefaultsKey = @"TSLastTempoUserDefaultsKey";
NSString * const kTSLastRotaryAngleUserDefaultsKey = @"TSRotaryAngleUserDefaultsKey";

@interface TSViewController () <TSClockDelegate, TSRotaryButtonDelegate>

@property (nonatomic, strong) TSClock *clock;

@property (nonatomic, strong) TSRotaryButton *btnTap;

@property (nonatomic, strong) TSDancingButton *btnConfused;
@property (nonatomic, strong) TSDancingButton *btnAlarmed;
@property (nonatomic, strong) TSDancingButton *btnMystery;

@property (nonatomic, strong) TSDancingButton *btnMute;
@property (nonatomic, assign) BOOL isMuted;

- (void)onTapBeat;
- (void)onTapConfused;
- (void)onTapAlarmed;
- (void)onTapMystery;
- (void)onTapMute;

- (void)updateUI;
- (void)appWillResign;

@end

@implementation TSViewController

- (id)init
{
    if (self = [super init]) {
        self.clock = [[TSClock alloc] init];
        _clock.delegate = self;
        _isMuted = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // the big enormous button
    self.btnTap = [[TSRotaryButton alloc] initWithFrame:CGRectMake(0, 0, 192.0f, 192.0f)];
    NSNumber *lastRotaryAngle = [[NSUserDefaults standardUserDefaults] objectForKey:kTSLastRotaryAngleUserDefaultsKey];
    if (lastRotaryAngle) {
        _btnTap.angle = [lastRotaryAngle floatValue];
    }
    _btnTap.subtitle = @"BPM";
    _btnTap.delegate = self;
    [self.view addSubview:_btnTap];
    
    UITapGestureRecognizer *tapButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBeat)];
    [_btnTap addGestureRecognizer:tapButton];
    
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
    
    // mute button
    self.btnMute = [[TSDancingButton alloc] initWithFrame:_btnConfused.frame];
    [_btnMute.internalButton setTitle:@"😵" forState:UIControlStateNormal];
    [self.view addSubview:_btnMute];
    
    UITapGestureRecognizer *tapMute = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapMute)];
    [_btnMute addGestureRecognizer:tapMute];
    
    // fire up the audio
    [TSPulseGen sharedInstance];
    
    // launch beat timer
    NSNumber *lastTempo = [[NSUserDefaults standardUserDefaults] objectForKey:kTSLastTempoUserDefaultsKey];
    if (lastTempo) {
        [_clock updateCurrentBPM:lastTempo.floatValue syncImmediately:YES];
    } else {
        [_clock updateCurrentBPM:120.0f syncImmediately:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResign) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResign) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _btnTap.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.view.bounds.size.height * 0.4f);
    
    _btnConfused.center = CGPointMake(self.view.bounds.size.width * 0.13f, self.view.bounds.size.height - 64.0f);
    _btnAlarmed.center = CGPointMake(self.view.bounds.size.width * 0.38f, _btnConfused.center.y);
    _btnMystery.center = CGPointMake(self.view.bounds.size.width * 0.62f, _btnConfused.center.y);
    _btnMute.center = CGPointMake(self.view.bounds.size.width * 0.87f, _btnConfused.center.y);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark delegate

- (void)clockDidBeat:(TSClock *)clock isPrimary:(BOOL)isPrimary
{
    if (!_isMuted) {
        // generate a pulse
        [[TSPulseGen sharedInstance] pulse];
    }
    
    if (isPrimary) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            // animate
            if (_isMuted) {
                [weakSelf.btnMute bounce];
            } else {
                [weakSelf.btnTap bounce];

                if (clock.isConfused) {
                    [weakSelf.btnConfused bounce];
                }
                if (clock.isAlarmed) {
                    [weakSelf.btnAlarmed bounce];
                }
                if (clock.isEnigmatic) {
                    [weakSelf.btnMystery bounce];
                    [weakSelf updateUI];
                }
            }
        });
    }
}

- (void)clock:(TSClock *)clock didUpdateTempo:(float)bpm
{
    [self updateUI];
}

- (void)rotaryButton:(TSRotaryButton *)button didChangeAngle:(CGFloat)deltaAngle
{
    float newBPM = _clock.currentBpm + deltaAngle;
    [_clock updateCurrentBPM:newBPM syncImmediately:NO];
}


#pragma mark internal

- (void)appWillResign
{
    [[NSUserDefaults standardUserDefaults] setObject:@(_clock.currentBpm) forKey:kTSLastTempoUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(_btnTap.angle) forKey:kTSLastRotaryAngleUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onTapBeat
{
    [_clock onTap];
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

- (void)onTapMute
{
    self.isMuted = !_isMuted;
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
