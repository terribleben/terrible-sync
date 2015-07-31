//
//  TSClock.h
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import <Foundation/Foundation.h>

#define TS_MIN_BPM 40.0f
#define TS_MAX_BPM 999.0f

@class TSClock;

@protocol TSClockDelegate <NSObject>

- (void)clockDidBeat: (TSClock *)clock;

@optional
- (void)clock: (TSClock *)clock didUpdateTempo: (float)bpm;

@end

@interface TSClock : NSObject

@property (nonatomic, assign) id<TSClockDelegate> delegate;
@property (nonatomic, assign) BOOL isConfused;
@property (nonatomic, assign) BOOL isAlarmed;

- (void)updateCurrentBPM:(float)bpm syncImmediately: (BOOL)syncImmediately;
- (void)increaseCurrentBPM;
- (void)decreaseCurrentBPM;
- (void)onTap;
- (void)stop;

@end
