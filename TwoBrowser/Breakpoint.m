//
//  Breakpoint.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "Breakpoint.h"

@implementation Breakpoint

@synthesize name;
@synthesize width;

- (id) init {
    self = [super init];
    if( self ) {
        name = @"320";
        width = 320;
    }
    
    return self;
}


@end
