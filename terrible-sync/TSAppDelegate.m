//
//  TSAppDelegate.m
//  terrible-sync
//
//  Created by Ben Roth on 7/30/15.
//
//

#import "TSAppDelegate.h"
#import "TSViewController.h"

@interface TSAppDelegate ()

@property (nonatomic, strong) TSViewController *vcRoot;

@end

@implementation TSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.vcRoot = [[TSViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = _vcRoot;
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
