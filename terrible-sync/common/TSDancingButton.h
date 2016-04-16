//
//  TSDancingButton.h
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat const kTSDancingButtonBounceDuration;

@interface TSDancingButton : UIView

@property (nonatomic, readonly) UIButton *internalButton;
@property (nonatomic, strong) NSString *subtitle;

/**
 *  Bounce bounce bounce
 *  bounce bounce bounce
 */
- (void)bounce;

@end
