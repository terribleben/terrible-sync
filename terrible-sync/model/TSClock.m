//
//  TSClock.m
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import "TSClock.h"

@import UIKit.UIApplication;
#import <sys/time.h>

long currentTimeUSec()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return (tp.tv_sec * 1000000 + tp.tv_usec);
}

@interface TSClock ()
{
    NSTimeInterval dtmLastTap;
    NSTimeInterval dtmLastLastTap;

    BOOL isNextBeatPrimary;
    BOOL isTimerRunning;
    dispatch_semaphore_t sThreadFinished;
}

@property (atomic, strong) NSNumber *currentBeatDuration;
@property (atomic, assign) long nextBeatTimeUSec;

- (void)scheduleNextBeat;
- (void)beat;
- (void)startTimerThread;
- (void)runTimer;

@end

@implementation TSClock

- (id)init
{
    if (self = [super init]) {
        dtmLastTap = 0;
        dtmLastLastTap = 0;
        _isAlarmed = NO;
        _isConfused = NO;
        _isEnigmatic = NO;
        self.currentBeatDuration = @(0);

        [self startTimerThread];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)stop
{
    self.nextBeatTimeUSec = 0;
    isTimerRunning = NO;

    if (sThreadFinished) {
        // wait for timer thread to stop spinning
        dispatch_semaphore_wait(sThreadFinished, DISPATCH_TIME_FOREVER);
        sThreadFinished = nil;
    }
    return;
}

- (void)onTap
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sinceLastTap = now - dtmLastTap;
    NSTimeInterval betweenPreviousTaps = dtmLastTap - dtmLastLastTap;
    
    float bpmLast = (sinceLastTap > 0) ? (60.0f / sinceLastTap) : 0;
    float bpmPrevious = (betweenPreviousTaps > 0) ? (60.0f / betweenPreviousTaps) : 0;
    
    float bpmAverage = 0;
    if (bpmPrevious >= TS_MIN_BPM && bpmLast >= TS_MIN_BPM)
        bpmAverage = (bpmPrevious + bpmLast) * 0.5f;
    else
        bpmAverage = bpmLast;
    
    [self updateCurrentBPM:bpmAverage syncImmediately:YES];
    
    dtmLastLastTap = dtmLastTap;
    dtmLastTap = now;
}

- (void)updateCurrentBPM:(float)bpm syncImmediately:(BOOL)syncImmediately
{
    if (bpm >= TS_MIN_BPM && bpm <= TS_MAX_BPM) {
        self.currentBeatDuration = @(60.0f / bpm);
        
        if (syncImmediately) {
            // schedule next beat immediately (to sync with tap)
            isNextBeatPrimary = YES;
            self.nextBeatTimeUSec = currentTimeUSec();
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(clock:didUpdateTempo:)]) {
            [_delegate clock:self didUpdateTempo:bpm];
        }
    }
}

- (void)increaseCurrentBPM
{
    [self updateCurrentBPM:(self.currentBpm + 1.0) syncImmediately:NO];
}

- (void)decreaseCurrentBPM
{
    [self updateCurrentBPM:(self.currentBpm - 1.0) syncImmediately:NO];
}

- (float)currentBpm
{
    return 60.0f / self.currentBeatDuration.floatValue;
}

- (void)dealloc
{
    [self stop];
}


#pragma mark internal

- (void)appWillResignActive
{
    // kill timer thread
    [self stop];
}

- (void)appDidBecomeActive
{
    // restart timer
    [self startTimerThread];
}

- (void)beat
{
    if (_delegate) {
        [_delegate clockDidBeat:self isPrimary:isNextBeatPrimary];
    }
    
    // continue beating
    isNextBeatPrimary = !isNextBeatPrimary;
    [self scheduleNextBeat];
}

- (void)scheduleNextBeat
{
    if (_isEnigmatic) {
        float enigmaticUpperBpm = TS_MAX_BPM * 0.33f;
        float randf = (float)rand() / (float)RAND_MAX;
        // less likely to change when at a high tempo
        float shouldChangeThreshold = 0.3f - (0.2f * (([self currentBpm] - TS_MIN_BPM) / (enigmaticUpperBpm - TS_MIN_BPM)));
        if (randf < shouldChangeThreshold) {
            randf = (float)rand() / (float)RAND_MAX;
            float newBpm = TS_MIN_BPM + (randf * ((enigmaticUpperBpm) - TS_MIN_BPM));
            self.currentBeatDuration = @(60.0f / newBpm);
        }
    }
    
    // seems like these instruments expect a sync pulse on their eighth note, so pulse at 0.5 * currentBeatDuration
    NSTimeInterval untilNextBeat = self.currentBeatDuration.floatValue * 0.5f;
    
    if (_isAlarmed) {
        untilNextBeat *= 0.5f;
    }
    if (_isConfused) {
        float randf = (float)rand() / (float)RAND_MAX;
        untilNextBeat *= (0.7f + (0.6f * randf));
    }
    self.nextBeatTimeUSec = currentTimeUSec() + MAX(1000, untilNextBeat * 1000000);
}

- (void)startTimerThread
{
    // reset / init
    [self stop];

    // separate timer thread
    isTimerRunning = YES;
    isNextBeatPrimary = YES;
    sThreadFinished = dispatch_semaphore_create(0);
    [NSThread detachNewThreadSelector:@selector(runTimer) toTarget:self withObject:nil];

    [self scheduleNextBeat];
}

- (void)runTimer
{
    [NSThread setThreadPriority:1.0];
    while (isTimerRunning) {
        long now = currentTimeUSec();
        if (now >= self.nextBeatTimeUSec) {
            self.nextBeatTimeUSec = 0;
            [self beat];
        }
        useconds_t sleepDuration = (unsigned int) MAX(1, 1000 - (currentTimeUSec() - now));
        usleep(sleepDuration);
    }
    if (sThreadFinished) {
        dispatch_semaphore_signal(sThreadFinished);
    }
}

@end
