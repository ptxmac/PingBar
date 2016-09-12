//
//  PingBarAppDelegate.h
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBPinger.h"

@interface PingBarAppDelegate : NSObject<NSApplicationDelegate> {
    NSWindow* __strong window;
    NSStatusItem* barItem;
    NSMenu* __strong menu;
    id defaultsObserver;
    NSTimer* pingTimer;
    PBPinger* pinger;
    NSOperationQueue* pingQueue;
    NSDate* lastReply;
}

@property(strong) IBOutlet NSWindow* window;
@property(strong) IBOutlet NSMenu* menu;

@property(readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property(readonly, strong, nonatomic) NSManagedObjectModel* managedObjectModel;

- (IBAction)showPreferences:(id)sender;
- (IBAction)startPinging:(id)sender;
- (IBAction)stopPinging:(id)sender;
- (IBAction)showAbout:(id)sender;
- (void)updateTime;

@end
