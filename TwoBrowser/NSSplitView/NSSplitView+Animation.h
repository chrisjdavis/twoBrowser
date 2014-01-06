//
//  NSSplitView+NSSplitView_Animation.h
//
//  Created by Michael Robinson on 8/05/12.
//  License: http://pagesofinterest.net/license/
//
//  Adapted from: http://cocoadev.com/wiki/AnimatedNSSplitView
//

#import <Cocoa/Cocoa.h>

@interface NSSplitView (Animation)

-(void) animateView:(int)viewIndex toDimension:(CGFloat)dimension;

@end
