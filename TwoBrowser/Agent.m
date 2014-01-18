//
//  Agent.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "Agent.h"

@implementation Agent

@synthesize name;
@synthesize agentString;

- (id) init {
    self = [super init];
    
    if( self ) {
        name = @"320";
        agentString = @"User Agent";
    }
    
    return self;
}

@end
