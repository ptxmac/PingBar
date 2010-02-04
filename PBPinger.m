//
//  PBPinger.m
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import "PBPinger.h"

@interface PBPinger (Private)

- (void)setup;

@end


@implementation PBPinger

@synthesize host;

- (NSTimeInterval)pingOnce {
    
    //NSLog(@"ping start");
    NSTask *task = [[NSTask alloc] init];
    
    NSDate *date = [NSDate date];
    
    [task setLaunchPath:@"/sbin/ping"];
    [task setArguments:[NSArray arrayWithObjects:
                        @"-o",
                        @"-c",@"1",
                        @"-q",
                        host,
                        nil]];
    
    NSPipe *pipe = [NSPipe pipe];
        
    [task setStandardOutput:pipe];
    [task launch];    
    [task waitUntilExit];        
    //[NSThread sleepForTimeInterval:4.0];
    //NSLog(@"ping done: %@",host);
    
    int termStatus = [task terminationStatus];
    [task release]; 
    
    NSFileHandle *hd = [pipe fileHandleForReading];
    
    NSData *data = [hd readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];        
    
        
    if (termStatus != 0) {
        NSLog(@"infinity: %i",termStatus);
        return -1.0;
    } else {
        
        __block NSTimeInterval dt = [[NSDate date] timeIntervalSinceDate:date];
        
        [string enumerateLinesUsingBlock:^(NSString *str, BOOL *stop) {
            if ([str hasPrefix:@"round-trip"]) {
                *stop = YES;
                NSArray *comps = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]];
                [comps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    float d = [obj floatValue];
                    if (d != 0.0) {
                        *stop = YES;
                        dt = d/1000.0;
                        //NSLog(@"Found: (%@) %f",obj,d);
                    }
                }];
            }
            
        }];
        
        
        return dt;
    }
}

+ (PBPinger *)pingerWithHost:(NSString *)host {
    return [[[PBPinger alloc] initWithHost:host] autorelease];
}

- (id)initWithHost:(NSString *)h {
    self = [super init];
    if (self != nil) {
        self.host = h;
        [self setup];
    }
    return self;
}

- (void)setup {
    
}


@end
