//
//  ITProgressBar.m
//  ITProgressBar
//
//  Created by Ilija Tovilo on 25/10/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import "ITProgressBar.h"

#define kStripesAnimationKey @"x"
#define kOpacityAnimationKey @"opacity"

#define kStripesOpacity 0.04
#define kColorTintLayerOpacity 0.2


@interface ITProgressBar ()
@property BOOL it_isHidden;
@property (strong, nonatomic, readonly) CALayer *stripesLayer;
@property (strong, nonatomic, readonly) CALayer *borderLayer;
@property (strong, nonatomic, readonly) CAGradientLayer *fillLayer;
@property (strong, nonatomic, readonly) CAGradientLayer *backgroundLayer;
@property (strong, nonatomic, readonly) CALayer *clipLayer;
@property (strong, nonatomic, readonly) CALayer *innerClipLayer;
@property (strong, nonatomic, readonly) CALayer *innerShadowLayer;
@property (strong, nonatomic, readonly) CALayer *colorTintLayer;
@end


@implementation ITProgressBar
@synthesize stripesLayer = _stripesLayer;
@synthesize borderLayer = _borderLayer;
@synthesize fillLayer = _fillLayer;
@synthesize backgroundLayer = _backgroundLayer;
@synthesize clipLayer = _clipLayer;
@synthesize innerClipLayer = _innerClipLayer;
@synthesize innerShadowLayer = _innerShadowLayer;
@synthesize colorTintLayer = _colorTintLayer;
@synthesize stripesImage = _stripesImage;


#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    // Initial values
    _borderWidth = 1.0;
    _shadowWidth = 1.0;
    _floatValue = 1.0;
    _animationDuration = 0.3;
    _stripesImage = [self stripesImageWithSize:NSMakeSize(30, 20)];
    
    // Enable Core Animation
    self.wantsLayer = YES;
    
    // Init layers
    self.fillLayer.colors = @[(id)[NSColor colorWithDeviceWhite:0.75 alpha:1.0].CGColor,
                              (id)[NSColor colorWithDeviceWhite:1.0 alpha:1.0].CGColor];
    
    [self.innerClipLayer addSublayer:self.fillLayer];
    [self.innerClipLayer addSublayer:self.stripesLayer];
    [self.innerClipLayer addSublayer:self.innerShadowLayer];
    [self.innerClipLayer addSublayer:self.colorTintLayer];
    
    [self.clipLayer addSublayer:self.backgroundLayer];
    [self.clipLayer addSublayer:self.borderLayer];
    [self.clipLayer addSublayer:self.innerClipLayer];
    
    [self.layer addSublayer:self.clipLayer];
    
    // Force update
    [self resizeLayers];
    
    // Start animation
    self.animates = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Update Layers

- (void)viewDidMoveToWindow
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewResized:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self];
}

- (void)viewResized:(NSNotification *)notification;
{
    [self resizeLayers];
}

- (void)resizeLayers {
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    {
        // Clip Layer
        self.clipLayer.frame = self.bounds;
        self.clipLayer.cornerRadius = (self.clipLayer.frame.size.height / 2);
        
        [self resizeInnerLayers];
        
        // Setting frames
        self.fillLayer.frame = self.bounds;
        self.borderLayer.frame = self.bounds;
        self.colorTintLayer.frame = self.bounds;
        self.backgroundLayer.frame = self.bounds;
        
        // Updating Content
        self.borderLayer.contents = [self borderImageForSize:self.bounds.size withInnerShadow:NO];
        NSImage *stripesImage = [self stripesImage];
        self.stripesLayer.backgroundColor = [NSColor colorWithPatternImage:stripesImage].CGColor;
        NSRect stripeFrame = self.bounds;
        stripeFrame.origin.x = -stripesImage.size.width;
        stripeFrame.size.width = (ceil(self.bounds.size.width / stripesImage.size.width) + 1) * stripesImage.size.width;
        self.stripesLayer.frame = stripeFrame;
    }
    [CATransaction commit];
}

- (void)reloadColorTint {
    self.colorTintLayer.backgroundColor = self.colorTint.CGColor;
}

- (void)resizeInnerLayers {
    self.innerClipLayer.frame = NSInsetRect(self.bounds, self.borderWidth, self.borderWidth);
    self.innerClipLayer.frame = (NSRect){ self.innerClipLayer.frame.origin,
                                          self.innerClipLayer.frame.size.width * self.floatValue,
                                          self.innerClipLayer.frame.size.height };
    self.innerClipLayer.cornerRadius = (self.innerClipLayer.frame.size.height / 2);
    
    self.innerShadowLayer.frame = NSInsetRect(self.innerClipLayer.bounds, -self.borderWidth, -self.borderWidth);
    self.innerShadowLayer.cornerRadius = (self.innerShadowLayer.frame.size.height / 2);
    self.innerShadowLayer.contents = [self borderImageForSize:self.innerShadowLayer.frame.size withInnerShadow:YES];
}


#pragma mark - NSAnimatablePropertyContainer

+ (id)defaultAnimationForKey:(NSString *)key
{
    if ([key isEqualToString:@"floatValue"]) {
        CABasicAnimation *anim = [CABasicAnimation animation];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        return anim;
    } else {
        return [super defaultAnimationForKey:key];
    }
}


#pragma mark - Setters & Getters

- (void)setFloatValue:(CGFloat)floatValue {
    if (floatValue < 0.0 || floatValue > 1.0) {
        @throw [NSException exceptionWithName:@"Invalid value"
                                       reason:@"Invalid value passed for `setFloatValue:`. Value must be between 0.0 and 1.0"
                                     userInfo:nil];
    }
    
    _floatValue = floatValue;
    
    [CATransaction begin]; {
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [self resizeInnerLayers];
    }[CATransaction commit];
}

- (void)setAnimationDuration:(CGFloat)animationDuration {
    _animationDuration = animationDuration;
    
    if (self.animates) {
        // Reload animation
        self.animates = NO;
        [self.stripesLayer removeAnimationForKey:kStripesAnimationKey];
        self.animates = YES;
    }
}

- (void)setColorTint:(NSColor *)colorTint {
    _colorTint = colorTint;
    [self reloadColorTint];
}

- (void)setHidden:(BOOL)flag {
    self.it_isHidden = flag;
    
    if (self.isHidden != flag) {
        if (flag) {
            [NSAnimationContext beginGrouping]; {
                [[NSAnimationContext currentContext] setCompletionHandler:^{
                    if (self.it_isHidden) [super setHidden:YES];
                    [self.stripesLayer removeAnimationForKey:kStripesAnimationKey];
                }];
                
                [self.animator setAlphaValue:0.0];
            } [NSAnimationContext endGrouping];
        } else {
            [NSAnimationContext beginGrouping]; {
                [super setHidden:NO];
                [self.animator setAlphaValue:1.0];
                
                if (self.animates) [self.stripesLayer addAnimation:[self stripesAnimation] forKey:kStripesAnimationKey];
            } [NSAnimationContext endGrouping];
        }
    }
}

- (void)setAnimates:(BOOL)animates {
    if (_animates != animates) {
        _animates = animates;
        
        if (_animates) {
            [CATransaction begin]; {
                if (![self.stripesLayer animationForKey:kStripesAnimationKey] && self.animates && !self.it_isHidden) {
                    [self.stripesLayer addAnimation:[self stripesAnimation] forKey:kStripesAnimationKey];
                }
                
                self.stripesLayer.opacity = kStripesOpacity;
            } [CATransaction commit];
        } else {
            [CATransaction setCompletionBlock:^{
                if ([self.stripesLayer animationForKey:kStripesAnimationKey] && !self.animates) {
                    [self.stripesLayer removeAnimationForKey:kStripesAnimationKey];
                }
            }];
            
            self.stripesLayer.opacity = 0.0;
        }
    }
}

- (CALayer *)stripesLayer {
    if (!_stripesLayer) {
        _stripesLayer = [CALayer layer];
        _stripesLayer.anchorPoint = NSMakePoint(0, 0.5);
        _stripesLayer.opacity = kStripesOpacity;
    }
    return _stripesLayer;
}

- (CALayer *)colorTintLayer {
    if (!_colorTintLayer) {
        _colorTintLayer = [CALayer layer];
        _colorTintLayer.opacity = kColorTintLayerOpacity;
    }
    return _colorTintLayer;
}

- (CAGradientLayer *)fillLayer {
    if (!_fillLayer) {
        _fillLayer = [CAGradientLayer layer];
    }
    return _fillLayer;
}

- (CAGradientLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAGradientLayer layer];
        _backgroundLayer.colors = @[
                                        (id)[NSColor colorWithDeviceWhite:0.55 alpha:1.0].CGColor,
                                        (id)[NSColor colorWithDeviceWhite:0.4 alpha:1.0].CGColor
                                    ];
    }
    return _backgroundLayer;
}

- (CALayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CALayer layer];
    }
    return _borderLayer;
}

- (CALayer *)clipLayer {
    if (!_clipLayer) {
        _clipLayer = [CALayer layer];
        _clipLayer.masksToBounds = YES;
    }
    
    return _clipLayer;
}

- (CALayer *)innerClipLayer {
    if (!_innerClipLayer) {
        _innerClipLayer = [CALayer layer];
        _innerClipLayer.masksToBounds = YES;
    }
    
    return _innerClipLayer;
}

- (CALayer *)innerShadowLayer {
    if (!_innerShadowLayer) {
        _innerShadowLayer = [CALayer layer];
    }
    
    return _innerShadowLayer;
}

- (void)setBorderWidth:(CGFloat)lineWidth {
    _borderWidth = lineWidth;
    if (self.shadowWidth > _borderWidth) self.shadowWidth = _borderWidth;
    
    [self updateLayer];
}

- (void)setShadowWidth:(CGFloat)shadowWidth {
    if (shadowWidth > self.borderWidth) {
        return NSLog(@"Warning: Line width must be at least as large as shadow width");
    }
    
    _shadowWidth = shadowWidth;
    [self updateLayer];
}

- (void)setStripesImage:(NSImage *)stripesImage {
    _stripesImage = stripesImage;
    [self updateLayer];
}


#pragma mark - Drawing

- (NSImage *)borderImageForSize:(NSSize)size withInnerShadow:(BOOL)innerShadowFlag {
    if (size.width <= 0 || size.height <= 0) return nil;
    
    return [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        //// Color Declarations
        NSColor* borderColor = [NSColor colorWithCalibratedRed: 0.291 green: 0.291 blue: 0.291 alpha: 1];
        NSColor* innerShadowColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
        
        //// Shadow Declarations
        NSShadow* innerShadow = [[NSShadow alloc] init];
        [innerShadow setShadowColor: [innerShadowColor colorWithAlphaComponent: 0.6]];
        [innerShadow setShadowOffset: NSMakeSize(0, -self.shadowWidth)];
        [innerShadow setShadowBlurRadius: 0];
        
        //// Frames
        NSRect baseFrame = (NSRect){ NSZeroPoint, size };
        
        
        //// BorderPath Drawing
        NSBezierPath* borderPathPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(baseFrame) + (self.borderWidth / 2), NSMinY(baseFrame) + (self.borderWidth / 2), NSWidth(baseFrame) - self.borderWidth, NSHeight(baseFrame) - self.borderWidth) xRadius:(baseFrame.size.height / 2) yRadius:(baseFrame.size.height / 2)];
        [NSGraphicsContext saveGraphicsState];
        if (innerShadowFlag) {
            [innerShadow set];
        }
        [borderColor setStroke];
        [borderPathPath setLineWidth: self.borderWidth];
        [borderPathPath stroke];
        [NSGraphicsContext restoreGraphicsState];
        
        return YES;
    }];
}

- (NSImage *)stripesImageWithSize:(NSSize)size {
    return [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        //// Color Declarations
        NSColor* color = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];
        
        //// Frames
        NSRect frame = (NSRect){ NSZeroPoint, size };
        
        //// WhiteBackground Drawing
        NSBezierPath* whiteBackgroundPath = [NSBezierPath bezierPathWithRect: NSMakeRect(NSMinX(frame), NSMinY(frame), NSWidth(frame), NSHeight(frame))];
        [[NSColor whiteColor] setFill];
        [whiteBackgroundPath fill];
        
        
        //// Stripe2 Drawing
        NSBezierPath* stripe2Path = [NSBezierPath bezierPath];
        [stripe2Path moveToPoint: NSMakePoint(NSMaxX(frame), NSMinY(frame))];
        [stripe2Path lineToPoint: NSMakePoint(NSMaxX(frame), NSMinY(frame) + 0.50000 * NSHeight(frame))];
        [stripe2Path lineToPoint: NSMakePoint(NSMinX(frame) + 0.50000 * NSWidth(frame), NSMaxY(frame))];
        [stripe2Path lineToPoint: NSMakePoint(NSMinX(frame), NSMaxY(frame))];
        [stripe2Path lineToPoint: NSMakePoint(NSMaxX(frame), NSMinY(frame))];
        [stripe2Path closePath];
        [color setFill];
        [stripe2Path fill];
        
        
        //// Stripe1 Drawing
        NSBezierPath* stripe1Path = [NSBezierPath bezierPath];
        [stripe1Path moveToPoint: NSMakePoint(NSMinX(frame), NSMinY(frame))];
        [stripe1Path lineToPoint: NSMakePoint(NSMinX(frame) + 0.50000 * NSWidth(frame), NSMinY(frame))];
        [stripe1Path lineToPoint: NSMakePoint(NSMinX(frame), NSMinY(frame) + 0.50000 * NSHeight(frame))];
        [stripe1Path lineToPoint: NSMakePoint(NSMinX(frame), NSMinY(frame))];
        [stripe1Path closePath];
        [[NSColor blackColor] setFill];
        [stripe1Path fill];
        
        return YES;
    }];
}


#pragma mark - Helpers

- (CABasicAnimation *)fadeAnimationVisible:(BOOL)visible {
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:kOpacityAnimationKey];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:(visible)?0:kStripesOpacity];
    fadeAnimation.toValue = [NSNumber numberWithFloat:(!visible)?0:kStripesOpacity];
    fadeAnimation.duration = 0.255;
    fadeAnimation.autoreverses = NO;
    
    return fadeAnimation;
}

- (CABasicAnimation *)stripesAnimation {
    CABasicAnimation *moveAnim;
    moveAnim          = [CABasicAnimation animationWithKeyPath:@"position.x"];
    moveAnim.fromValue = @( -self.stripesImage.size.width );
    moveAnim.byValue  = @( self.stripesImage.size.width );
    moveAnim.duration = self.animationDuration;
    moveAnim.removedOnCompletion = NO;
    moveAnim.delegate = self;
    moveAnim.repeatCount = HUGE_VAL;
    moveAnim.autoreverses = NO;
    
    return moveAnim;
}

@end
