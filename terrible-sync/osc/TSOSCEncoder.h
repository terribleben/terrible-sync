//
//  TSOSCEncoder.h
//  terrible-sync
//
//  Created by Ben Roth on 8/16/16.
//
//

#import <Foundation/Foundation.h>

@interface TSOSCEncoder : NSObject

+ (instancetype)sharedInstance;

- (void)broadcastStepWithId: (NSNumber *)stepId;

@end
