//
//  Agent.h
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Agent : NSObject {
@private
    NSString *name;
    NSString *agentString;
}

@property (copy) NSString *name;
@property (copy) NSString *agentString;

@end
