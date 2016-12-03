//
//  TSOSCEncoder.m
//  terrible-sync
//
//  Created by Ben Roth on 8/16/16.
//
//

#import "TSOSCEncoder.h"
#import "F53OSC.h"

NSString * const kTSCOSCAddressPatternBase = @"ts";

@interface TSOSCEncoder ()

@property (nonatomic, strong) F53OSCClient *oscClient;

@end

@implementation TSOSCEncoder

+ (instancetype) sharedInstance
{
    static TSOSCEncoder *theEncoder = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!theEncoder) {
            theEncoder = [[TSOSCEncoder alloc] init];
        }
    });
    return theEncoder;
}

- (instancetype)init
{
    if (self = [super init]) {
        _oscClient = [[F53OSCClient alloc] init];
        _oscClient.host = @"192.168.0.102"; // TODO: kill me
        _oscClient.port = 4242;
        [_oscClient connect];
    }
    return self;
}

- (void)dealloc
{
    [self _disconnect];
}

- (void)broadcastStepWithId:(NSNumber *)stepId
{
    NSAssert(stepId, @"Can't broadcast a step with no id");
    [self _sendMessageWithRelativeAddress:@"step" arguments:@[ stepId ]];
}

#pragma mark - Internal

- (void)_sendMessageWithRelativeAddress:(NSString *)address arguments:(NSArray *)arguments
{
    NSString *addressPattern = [NSString stringWithFormat:@"/%@/%@", kTSCOSCAddressPatternBase, address];
    F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:addressPattern arguments:arguments];
    [_oscClient sendPacket:message];
}

- (void)_disconnect
{
    if (_oscClient.isConnected) {
        [_oscClient disconnect];
    }
}

@end
