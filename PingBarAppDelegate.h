//
//  PingBarAppDelegate.h
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PingBarAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSStatusItem *barItem;
}

@property (assign) IBOutlet NSWindow *window;

@end
