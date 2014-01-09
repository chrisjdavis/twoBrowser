//
//  TwoSplitController.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/9/14.
//  Copyright (c) 2014 ___LEAGUEOFBEARDS___. All rights reserved.
//

#import "TwoSplitController.h"

@implementation TwoSplitController

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView*)view {
	if( view == [[splitView subviews] objectAtIndex:0]) {
		return NO;
	} else {
		return YES;
	}
}

@end