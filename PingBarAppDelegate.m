//
//  PingBarAppDelegate.m
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import "PingBarAppDelegate.h"
#import "PSYBlockTimer.h"

@implementation PingBarAppDelegate

@synthesize window,menu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set default preferences
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs registerDefaults:[NSDictionary 
                            dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:1.0],@"pingDelay",
                            @"localhost",@"pingHost",
                            [NSNumber numberWithInteger:10],@"maxPings",
                            [NSNumber numberWithBool:NO],@"doPing",
                            [NSNumber numberWithInteger:0],@"timePrecision",
                            nil]];
    
    
    pingQueue = [[NSOperationQueue alloc] init];
    
	// Listen for preferences changes.
    // NSUserDefaultsDidChangeNotification
    defaultsObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                                         object:defs
                                                                          queue:nil
                                                                     usingBlock:^(NSNotification *n) {
                                                                         
                                                                         //NSLog(@"Pref changed");
                                                                         // stop pinging
                                                                         [self stopPinging:nil];
                                                                         [self startPinging:nil];
                                                  }];
    // show the menu
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [barItem setTitle:@"PingBar"];
    [barItem setHighlightMode:YES];
    [barItem setMenu:menu];
    
    [self startPinging:nil];
}

- (IBAction)stopPinging:(id)sender {
    if (pingTimer) [pingTimer invalidate];
}

- (void)updateTime {
    NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:lastReply];
    
    int p = [[NSUserDefaults standardUserDefaults] integerForKey:@"timePrecision"];
    // Evil double format :D
    NSString *str = [NSString stringWithFormat:@"%%.%df",p];
    [barItem setTitle:[NSString stringWithFormat:str,secs]];                                                 
    
}

- (IBAction)startPinging:(id)sender {
    BOOL doPing = [[NSUserDefaults standardUserDefaults] boolForKey:@"doPing"];
    if (!doPing)
        return;
    //NSLog(@"Let's ping");
    //if (pinger)  // end
    pinger = [PBPinger pingerWithHost:[[NSUserDefaults standardUserDefaults] stringForKey:@"pingHost"]];        
    
    lastReply = [NSDate date];
    
    // + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock;
    pingTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] floatForKey:@"pingDelay"]
                                                repeats:YES
                                             usingBlock:^(NSTimer *timer) {
                                                 // Set time
                                                 [self updateTime];
                                                                                                 
                                                 int maxPings = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxPings"];
                                                 if ([pingQueue operationCount] < maxPings) {
                                                     [pingQueue addOperationWithBlock:^{
                                                         NSTimeInterval delay = [pinger pingOnce];
                                                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                             if (delay >= 0.0) {
                                                                 NSLog(@"not inf: %f",delay);
                                                                 lastReply = [NSDate date];                                                               
                                                             }
                                                             [self updateTime];
                                                         }];
                                                     }];
                                                 }
                                             }];
}

- (IBAction)showPreferences:(id)sender {

    //[window orderFrontRegardless];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];

}



@end
