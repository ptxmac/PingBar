//
//  PingBarAppDelegate.m
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import "PingBarAppDelegate.h"

@implementation PingBarAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    // show the menu
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [barItem setTitle:@"42"];
    
}

@end
