//
//  TSRotaryButton.h
//  terrible-sync
//
//  Created by Ben Roth on 4/16/16.
//
//

#import "TSDancingButton.h"

@class TSRotaryButton;

@protocol TSRotaryButtonDelegate <NSObject>

- (void)rotaryButton: (TSRotaryButton *)button didChangeAngle: (CGFloat)deltaAngle;

@end

@interface TSRotaryButton : TSDancingButton

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) id<TSRotaryButtonDelegate> delegate;

@end
