//
//  Breakpoint.h
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Breakpoint : NSObject {

@private
    NSString *name;
    int width;
}

@property (copy) NSString *name;
@property int width;

@end
