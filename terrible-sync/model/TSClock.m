//
//  TSClock.m
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import "TSClock.h"

@interface TSClock ()
{
    NSTimeInterval dtmLastTap;
    NSTimeInterval dtmLastLastTap;
}

@property (nonatomic, strong) NSTimer *tmrBeat;
@property (atomic, strong) NSNumber *currentBeatDuration;

- (void)scheduleNextBeat;
- (void)beat;

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
    }
    return self;
}

- (void)stop
{
    if (_tmrBeat) {
        [_tmrBeat invalidate];
        _tmrBeat = nil;
    }
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
        // round to nearest half-bpm (better for programming the tempo into other objects)
        float approxBpm = roundf(bpm * 2.0f) * 0.5f;
        
        self.currentBeatDuration = @(60.0f / approxBpm);
        
        if (syncImmediately) {
            // schedule next beat immediately (to sync with tap)
            [self scheduleNextBeat];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(clock:didUpdateTempo:)]) {
            [_delegate clock:self didUpdateTempo:approxBpm];
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
    [self stop];
    // don't use a repeating timer because the duration could change between timer fires.
    
    if (_isEnigmatic) {
        float randf = (float)rand() / (float)RAND_MAX;
        if (randf < 0.2f) {
            randf = (float)rand() / (float)RAND_MAX;
            float newBpm = TS_MIN_BPM + (randf * ((TS_MAX_BPM * 0.33f) - TS_MIN_BPM));
            self.currentBeatDuration = @(60.0f / newBpm);
        }
    }
    
    NSTimeInterval untilNextBeat = self.currentBeatDuration.floatValue;
    if (_isAlarmed) {
        untilNextBeat *= 0.5f;
    }
    if (_isConfused) {
        float randf = (float)rand() / (float)RAND_MAX;
        untilNextBeat *= (0.7f + (0.6f * randf));
    }
    _tmrBeat = [NSTimer scheduledTimerWithTimeInterval:untilNextBeat target:self selector:@selector(beat) userInfo:nil repeats:NO];
}

@end
