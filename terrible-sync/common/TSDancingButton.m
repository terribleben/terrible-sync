//
//  TSDancingButton.m
//  terrible-sync
//
//  Created by Ben Roth on 7/31/15.
//
//

#import "TSDancingButton.h"

CGFloat const kTSDancingButtonBounceDuration = 0.25f;

@interface TSDancingButton ()

@property (nonatomic, strong) UIButton *internalButton;
@property (nonatomic, strong) UILabel *lblSubtitle;
@property (nonatomic, strong) UIView *vHitArea;
@property (nonatomic, strong) UIView *vBounceAnimation;

@end

@implementation TSDancingButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        // animation view
        self.vBounceAnimation = [[UIView alloc] init];
        _vBounceAnimation.backgroundColor = [UIColor whiteColor];
        _vBounceAnimation.clipsToBounds = YES;
        [self addSubview:_vBounceAnimation];
        
        // wrap around a normal button
        self.internalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _internalButton.clipsToBounds = YES;
        _internalButton.backgroundColor = [UIColor blackColor];
        _internalButton.layer.borderWidth = 6.0f / [UIScreen mainScreen].scale;
        _internalButton.layer.borderColor = [UIColor redColor].CGColor;
        _internalButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
        [_internalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_internalButton];
        
        // subtitle label
        self.lblSubtitle = [[UILabel alloc] init];
        _lblSubtitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
        _lblSubtitle.textColor = [UIColor lightGrayColor];
        _lblSubtitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_lblSubtitle];
        
        // hit area view-- because the animated button has trouble detecting hits accurately
        self.vHitArea = [[UIView alloc] init];
        _vHitArea.backgroundColor = [UIColor clearColor];
        [self addSubview:_vHitArea];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _internalButton.frame = self.bounds;
    _internalButton.layer.cornerRadius = MIN(_internalButton.frame.size.width, _internalButton.frame.size.height) * 0.5f;
    
    _lblSubtitle.frame = CGRectMake(0, 0, _internalButton.frame.size.width, 12.0f);
    _lblSubtitle.center = CGPointMake(_internalButton.center.x, _internalButton.center.y + 20.0f);
    
    _vBounceAnimation.frame = _internalButton.frame;
    _vBounceAnimation.layer.cornerRadius = _internalButton.layer.cornerRadius;
    
    _vHitArea.frame = _internalButton.frame;
}

- (void)bounce
{
    _vBounceAnimation.transform = CGAffineTransformIdentity;
    _internalButton.transform = CGAffineTransformIdentity;
    
    _vBounceAnimation.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    _internalButton.transform = CGAffineTransformMakeScale(0.96f, 0.96f);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kTSDancingButtonBounceDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        weakSelf.vBounceAnimation.transform = CGAffineTransformIdentity;
        weakSelf.internalButton.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
