//
//  TSPulseGen.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import <UIKit/UIKit.h>

#import "TSPulseGen.h"
#import "TSAudio.h"
#import "TSAudioDef.h"

@interface TSPulseGen ()
{
    BOOL isPulsing;
}

@property (nonatomic, strong) TSAudio *theAudio;

- (void)onBackground;
- (void)onForegroundOrLoad;

@end

void audioCallback(Sample* buffer, unsigned int numFrames, void* userData);

@implementation TSPulseGen

+ (instancetype) sharedInstance
{
    static TSPulseGen *theGen = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theGen) {
            theGen = [[TSPulseGen alloc] init];
        }
    });
    return theGen;
}

- (id)init
{
    if (self = [super init]) {
        isPulsing = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onForegroundOrLoad) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBackground) name:UIApplicationWillResignActiveNotification object:nil];
        
        self.theAudio = [[TSAudio alloc] initWithSampleRate:TS_AUDIO_SAMPLE_RATE
                                                 bufferSize:TS_AUDIO_BUFFER_SIZE
                                                   callback:audioCallback userData:nil];
        if (![_theAudio startSession]) {
            NSLog(@"%s: Failed to enable audio", __func__);
        }
    }
    return self;
}


#pragma mark internal

- (void)onForegroundOrLoad
{
    [_theAudio startSession];
}

- (void)onBackground
{
    [_theAudio suspendSession];
}

- (void)pulse
{
    
}

@end


#pragma mark c/audio

void audioCallback(Sample* buffer, unsigned int nFrames, void* userData) {
    memset(buffer, 0, TS_AUDIO_NUM_CHANNELS * nFrames * sizeof(Sample));
    
    for (unsigned int ii = 0; ii < nFrames; ii++) {
        // TODO: write audio frame
        buffer += TS_AUDIO_NUM_CHANNELS;
    }
    return;
}
