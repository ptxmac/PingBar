//
//  PingBarAppDelegate.h
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBPinger.h"

@interface PingBarAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSStatusItem *barItem;
    NSMenu *menu;
    id defaultsObserver;
    NSTimer *pingTimer;
    PBPinger *pinger;
    NSOperationQueue *pingQueue;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *menu;

- (IBAction)showPreferences:(id)sender;
- (IBAction)startPinging:(id)sender;
- (IBAction)stopPinging:(id)sender;

@end
