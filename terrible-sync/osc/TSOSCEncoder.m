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
NSString * const kTSOSCHostKey = @"TSOSCHost";
NSString * const kTSOSCPortKey = @"TSOSCPort";

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
        NSString *oscHost = [[[NSBundle mainBundle] infoDictionary] objectForKey:kTSOSCHostKey];
        NSNumber *oscPort = [[[NSBundle mainBundle] infoDictionary] objectForKey:kTSOSCPortKey];
        if (oscHost) {
            _oscClient = [[F53OSCClient alloc] init];
            _oscClient.host = oscHost;
            _oscClient.port = (oscPort) ? oscPort.integerValue : 4242;
            [_oscClient connect];
        }
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
    if (_oscClient) {
        NSString *addressPattern = [NSString stringWithFormat:@"/%@/%@", kTSCOSCAddressPatternBase, address];
        F53OSCMessage *message = [F53OSCMessage messageWithAddressPattern:addressPattern arguments:arguments];
        [_oscClient sendPacket:message];
    }
}

- (void)_disconnect
{
    if (_oscClient && _oscClient.isConnected) {
        [_oscClient disconnect];
    }
    _oscClient = nil;
}

@end
