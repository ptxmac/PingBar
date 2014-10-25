//
//  PBPinger.h
//  PingBar
//
//  Created by Peter Kristensen on 04/02/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PBPinger : NSObject {
    
    NSString *host;
    
}

@property (strong) NSString *host;

+ (PBPinger *)pingerWithHost:(NSString *)host;
- (id)initWithHost:(NSString *)host;
- (NSTimeInterval)pingOnce;

@end

static __inline__ CGFloat LSRandomFloatBetween(CGFloat a, CGFloat b)
{
    return a + (b - a) * ((CGFloat) random() / (CGFloat) RAND_MAX);
}
