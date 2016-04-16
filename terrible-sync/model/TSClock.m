//
//  TSClock.m
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import "TSClock.h"
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

    long nextBeatTimeUSec;
    BOOL isTimerRunning;
}

@property (atomic, strong) NSNumber *currentBeatDuration;

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
    }
    return self;
}

- (void)stop
{
    nextBeatTimeUSec = 0;
    isTimerRunning = NO;
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
            [self scheduleNextBeat];
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

- (void)beat
{
    if (_delegate) {
        [_delegate clockDidBeat:self];
    }
    
    // continue beating
    [self scheduleNextBeat];
}

- (void)scheduleNextBeat
{
    if (_isEnigmatic) {
        float randf = (float)rand() / (float)RAND_MAX;
        if (randf < 0.2f) {
            randf = (float)rand() / (float)RAND_MAX;
            float newBpm = TS_MIN_BPM + (randf * ((TS_MAX_BPM * 0.33f) - TS_MIN_BPM));
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
    nextBeatTimeUSec = currentTimeUSec() + (untilNextBeat * 1000000);
}

- (void)startTimerThread
{
    // reset / init
    [self stop];

    // separate timer thread
    isTimerRunning = YES;
    [NSThread detachNewThreadSelector:@selector(runTimer) toTarget:self withObject:nil];
}

- (void)runTimer
{
    while (isTimerRunning) {
        long now = currentTimeUSec();
        if (now >= nextBeatTimeUSec) {
            [self beat];
        }
        useconds_t sleepDuration = (unsigned int) MAX(1, 1000 - (currentTimeUSec() - now));
        usleep(sleepDuration);
    }
}

@end
