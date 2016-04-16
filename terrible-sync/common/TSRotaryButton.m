//
//  TSRotaryButton.m
//  terrible-sync
//
//  Created by Ben Roth on 4/16/16.
//
//

#import "TSRotaryButton.h"

#define M_2PI 6.28318530717959

float diffAngle(float a, float b)
{
    while (a > M_2PI) a -= M_2PI;
    while (b > M_2PI) b -= M_2PI;
    while (a < 0) a += M_2PI;
    while (b < 0) b += M_2PI;
    
    float diff = a - b;
    if (fabs(diff) <= M_PI) return diff;
    
    while (a > M_PI) a -= M_2PI;
    while (b > M_PI) b -= M_2PI;
    while (a < -M_PI) a += M_2PI;
    while (b < -M_PI) b += M_2PI;
    
    return a - b;
}

float angleToPositionInRect(CGRect rect, CGPoint position)
{
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint relativePosition = CGPointMake(position.x - center.x, position.y - center.y);
    return atan2f(relativePosition.y, relativePosition.x);
}

@interface TSRotaryButton ()

@property (nonatomic, assign) CGPoint previousPanPosition;
@property (nonatomic, strong) UIView *vPointerContainer;
@property (nonatomic, strong) UIImageView *vPointer;

@end

@implementation TSRotaryButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _angle = 0;
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
        [self addGestureRecognizer:panGR];
        
        self.vPointerContainer = [[UIView alloc] initWithFrame:self.bounds];
        _vPointerContainer.userInteractionEnabled = NO;
        [self addSubview:_vPointerContainer];
        
        self.vPointer = [[UIImageView alloc] initWithFrame:_vPointerContainer.bounds];
        _vPointer.image = [UIImage imageNamed:@"rotary"];
        _vPointer.userInteractionEnabled = NO;
        [_vPointerContainer addSubview:_vPointer];
    }
    return self;
}

#pragma mark - internal

- (void)setAngle:(CGFloat)angle
{
    CGFloat delta = angle - _angle;
    _angle = angle;
    
    _vPointer.transform = CGAffineTransformMakeRotation(_angle);
    if (_delegate && delta != 0) {
        [_delegate rotaryButton:self didChangeAngle:delta];
    }
}

- (void)_handlePan: (UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _previousPanPosition = [pan locationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint panPosition = [pan locationInView:self];
            CGFloat newAngle = angleToPositionInRect(self.bounds, panPosition);
            CGFloat prevAngle = angleToPositionInRect(self.bounds, _previousPanPosition);
            
            [self setAngle:_angle + diffAngle(newAngle, prevAngle)];
            _previousPanPosition = panPosition;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            _previousPanPosition = CGPointZero;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)bounce
{
    [super bounce];
    
    _vPointerContainer.transform = CGAffineTransformIdentity;
    
    _vPointerContainer.transform = CGAffineTransformMakeScale(0.96f, 0.96f);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:kTSDancingButtonBounceDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        weakSelf.vPointerContainer.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
