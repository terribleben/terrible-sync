//
//  TSClock.h
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import <Foundation/Foundation.h>

#define TS_MIN_BPM 20.0f
#define TS_MAX_BPM 999.0f

@class TSClock;

@protocol TSClockDelegate <NSObject>

/**
 *  Not called on main thread!
 */
- (void)clockDidBeat: (TSClock *)clock isPrimary: (BOOL)isPrimary;

@optional
- (void)clock: (TSClock *)clock didUpdateTempo: (float)bpm;

@end

@interface TSClock : NSObject

@property (nonatomic, assign) id<TSClockDelegate> delegate;

@property (nonatomic, readonly) float currentBpm;
@property (nonatomic, assign) BOOL isConfused;
@property (nonatomic, assign) BOOL isAlarmed;
@property (nonatomic, assign) BOOL isEnigmatic;

- (void)updateCurrentBPM:(float)bpm syncImmediately: (BOOL)syncImmediately;
- (void)increaseCurrentBPM;
- (void)decreaseCurrentBPM;
- (void)onTap;
- (void)stop;

@end
