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

@synthesize window, menu;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    // Set default preferences
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    [defs registerDefaults:@{
        @"pingDelay" : @1.0f,
        @"pingHost" : @"localhost",
        @"maxPings" : @10,
        @"doPing" : @NO,
        @"timePrecision" : @0,
        @"showDock" : @NO
    }];

    pingQueue = [[NSOperationQueue alloc] init];

    // Listen for preferences changes.
    // NSUserDefaultsDidChangeNotification
    defaultsObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:NSUserDefaultsDidChangeNotification
                    object:defs
                     queue:nil
                usingBlock:^(NSNotification* n) {
                    // NSLog(@"Pref changed");
                    // stop pinging
                    [self stopPinging:nil];
                    [self startPinging:nil];
                }];
    // show the menu
    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    barItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [barItem setTitle:@"PingBar"];
    [barItem setHighlightMode:YES];
    [barItem setMenu:menu];

    [self startPinging:nil];

    [self updateDockIcon:nil];
}

- (IBAction)updateDockIcon:(id)sender {
    BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:@"showDock"];
    [NSApp setActivationPolicy:show ? NSApplicationActivationPolicyRegular
                                    : NSApplicationActivationPolicyProhibited];
}

- (IBAction)stopPinging:(id)sender {
    if (pingTimer)
        [pingTimer invalidate];
}

- (void)updateTime {
    NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:lastReply];

    int p =
        [[NSUserDefaults standardUserDefaults] integerForKey:@"timePrecision"];
    // Evil double format :D
    NSString* str = [NSString stringWithFormat:@"%%.%df", p];
    [barItem setTitle:[NSString stringWithFormat:str, secs]];
}

- (IBAction)startPinging:(id)sender {
    BOOL doPing = [[NSUserDefaults standardUserDefaults] boolForKey:@"doPing"];
    if (!doPing)
        return;
    // NSLog(@"Let's ping");
    // if (pinger)  // end
    pinger = [PBPinger pingerWithHost:[[NSUserDefaults standardUserDefaults]
                                          stringForKey:@"pingHost"]];

    lastReply = [NSDate date];

    [self updateTime];
    // + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
    // repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))fireBlock;
    pingTimer = [NSTimer
        scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults]
                                           floatForKey:@"pingDelay"]
                               repeats:YES
                            usingBlock:^(NSTimer* timer) {
                                // Set time

                                int maxPings =
                                    [[NSUserDefaults standardUserDefaults]
                                        integerForKey:@"maxPings"];
                                if ([pingQueue operationCount] < maxPings) {
                                    [pingQueue addOperationWithBlock:^{
                                        NSTimeInterval delay =
                                            [pinger pingOnce];
                                        [[NSOperationQueue mainQueue]
                                            addOperationWithBlock:^{
                                                if (delay >= 0.0) {
                                                    // NSLog(@"not inf:
                                                    // %f",delay);
                                                    lastReply = [[NSDate date]
                                                        dateByAddingTimeInterval:
                                                            -delay];
                                                }
                                                [self updateTime];
                                            }];
                                    }];
                                } else
                                    [self updateTime];
                            }];
}

- (IBAction)showPreferences:(id)sender {

    //[window orderFrontRegardless];
    [window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)showAbout:(id)sender {
    [NSApp orderFrontStandardAboutPanel:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (NSURL*)applicationDocumentsDirectory {
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSURL* appSupport = [[mgr URLsForDirectory:NSApplicationSupportDirectory
                                     inDomains:NSUserDomainMask] lastObject];

    NSURL* url =
        [appSupport URLByAppendingPathComponent:@"dk.luckysoftware.Pingbar"];

    BOOL dir;
    if (![mgr fileExistsAtPath:url.path isDirectory:&dir] || !dir) {
        [mgr createDirectoryAtPath:url.path
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:nil];
    }

    return url;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSPersistentStoreCoordinator* coordinator =
            [[NSPersistentStoreCoordinator alloc]
                initWithManagedObjectModel:self.managedObjectModel];

        NSURL* applicationDirectory = [self applicationDocumentsDirectory];

        NSURL* url =
            [applicationDirectory URLByAppendingPathComponent:@"Hosts.xml"];
        NSLog(@"Path: %@", url);
        NSError* error;
        [coordinator addPersistentStoreWithType:NSXMLStoreType
                                  configuration:nil
                                            URL:url
                                        options:nil
                                          error:&error];

        _persistentStoreCoordinator = coordinator;
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel*)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"PingBarModel"
                                                  withExtension:@"momd"];
        _managedObjectModel =
            [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSManagedObjectContext*)managedObjectContext {
    if (!_managedObjectContext) {

        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator =
            self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:
                                   (NSApplication*)sender {
    [self.managedObjectContext save:nil];
    return NSTerminateNow;
}

@end
