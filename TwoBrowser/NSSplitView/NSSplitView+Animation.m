//
//  NSSplitView+NSSplitView_Animation.m
//
//  Created by Michael Robinson on 8/05/12.
//  License: http://pagesofinterest.net/license/
//
//  Adapted from: http://cocoadev.com/wiki/AnimatedNSSplitView
//

#import "NSSplitView+Animation.h"

@implementation NSSplitView (Animation)

/**
 * Animate the split view panels such that the view at viewIndex has the width or height dimension.
 * Note that animating a panel to zero width or height will cause it to 'disappear', and such a panel will not animate again. Animating to no less than 1 pixel wide or high is sufficient to make a panel appear hidden.
 * @param viewIndex The index of the view to animate to dimension wide or high
 * @param dimension The width or height, depending on whether the NSSplitView is horizontally or vertically split, to animate to
 */
- (void) animateView:(int)viewIndex toDimension:(CGFloat)dimension {

    NSView *targetView = [[self subviews] objectAtIndex:viewIndex];
    NSRect endFrame = [targetView frame];

    if (![self isVertical]) {
        endFrame.size.height = dimension;
    } else {
        endFrame.size.width = dimension;
    }

    NSDictionary *windowResize;

    windowResize = [NSDictionary dictionaryWithObjectsAndKeys: targetView, NSViewAnimationTargetKey,
                    [NSValue valueWithRect: endFrame], NSViewAnimationEndFrameKey, nil];

    NSViewAnimation *animation = [[NSViewAnimation alloc]
                                  initWithViewAnimations:[NSArray arrayWithObject:windowResize]];


    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setDuration:0.5];
    [animation startAnimation];
}

@end
