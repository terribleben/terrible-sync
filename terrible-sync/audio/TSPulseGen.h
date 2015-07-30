//
//  TSPulseGen.h
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import <Foundation/Foundation.h>

@interface TSPulseGen : NSObject

+ (instancetype)sharedInstance;

- (void)pulse;

@end
