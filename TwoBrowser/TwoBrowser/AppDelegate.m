//
//  AppDelegate.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/3/14.
//  Copyright (c) 2014 ___LEAGUEOFBEARDS___. All rights reserved.
//

#import "AppDelegate.h"
#import "INWindowButton.h"

@interface AppDelegate ()

- (IBAction)connectURL:(id)sender;
- (IBAction)reloadURL:(id)sender;

@end;

@implementation AppDelegate

@synthesize textField;
@synthesize mobileView;
@synthesize desktopView;
@synthesize theSplits = theSplits_;
@synthesize toggler;
@synthesize breakpoints;
@synthesize url;
@synthesize urlButton;
@synthesize bookmarkAdd;
@synthesize pageTitle;
@synthesize pageFavicon;
@synthesize desktopWidth;
@synthesize mobileWidth;
@synthesize sizeDivider;

- (void) awakeFromNib {
    [self loadWelcome];
    NSAppleEventManager *eventManager = [NSAppleEventManager sharedAppleEventManager];
    [eventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    [theSplits_ setAutosaveName:@"2splitView"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // setup some cache defaults.
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSAppleEventManager *eventManager = [NSAppleEventManager sharedAppleEventManager];
    [eventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    self.windowControllers = [NSMutableArray array];
    self.window.trafficLightButtonsLeftMargin = 9.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.centerFullScreenButton = YES;
    self.window.titleBarHeight = 40.0;
    self.titleView.frame = self.window.titleBarView.bounds;
    self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.titleBarView addSubview:self.titleView];
    
    [theSplits_ setPosition:320 - 3 ofDividerAtIndex:0];
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStartLoad:)name:WebViewProgressStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewFinishedLoading:)name:WebViewProgressFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize:)name:NSSplitViewDidResizeSubviewsNotification object: nil];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *prefixToRemove = @"two://";
    NSString *newString = nil;
    
    if ([urlString hasPrefix:prefixToRemove]) {
        newString = [urlString substringFromIndex:[prefixToRemove length]];
        [self connectURL:newString];
    }
}

#pragma mark -- respsonsive breakpoints

- (IBAction)chooseBreakpoint:(id)sender {
    switch (breakpoints.indexOfSelectedItem) {
        case 1:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:320 - 3];
            break;
        case 2:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:360 - 3];
            break;
        case 3:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:768 - 3];
            break;
        case 4:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:800 - 3];
            break;
        case 5:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:980 - 3];
            break;
        default:
            [mobileView setHidden:NO];
            [theSplits_ animateView:0 toDimension:320 - 3];
        break;
    }
    
    NSInteger indexOfSelectedItem = [breakpoints indexOfSelectedItem];
    
    [breakpoints selectItemAtIndex:indexOfSelectedItem];
    
    toggler.selectedSegment = 0;
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    [theSplits_ adjustSubviews];
}

#pragma mark -- SplitVIiew crap

- (IBAction)toggleControl:(id)sender {
    switch ((((NSSegmentedControl *)sender).selectedSegment)) {
        case 0:
            [theSplits_ animateView:0 toDimension:320];
            [theSplits_ adjustSubviews];
            [mobileView setHidden:NO];
            [mobileWidth setHidden:NO];
            break;
        case 1:
            [mobileView setHidden:YES];
            [mobileWidth setHidden:YES];
            [theSplits_ animateView:0 toDimension:1];
            [theSplits_ adjustSubviews];
            break;
        default:
        break;
    }
}

- (void)didResize:(NSNotification *)notification {
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
}

#pragma mark -- webKit Specific

- (void)loadWelcome {
    NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
    NSURLRequest *localRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:localFilePath]];
    [[mobileView mainFrame] loadRequest:localRequest];
    [[desktopView mainFrame] loadRequest:localRequest];
}

- (void)webViewDidStartLoad:(NSNotification *)notification {
    [pageFavicon setHidden:YES];
    [self.progr startAnimation:[notification object]];
}

- (void)webViewFinishedLoading:(NSNotification *)notification {
    [self.progr stopAnimation:[notification object]];
    
    NSString * TitleString = [NSString stringWithFormat:@"Testing %@", [[notification object] mainFrameTitle]];
    NSString * newURLString = [NSString stringWithFormat:@"%@", [[notification object] mainFrameURL]];
    
    
    if( [self contains:@"file://" on:newURLString] == false ) {
        [textField setStringValue:newURLString];
    }
    
    [pageFavicon setHidden:NO];
    [pageTitle setStringValue:TitleString];
    [pageFavicon setImage:[[notification object] mainFrameIcon]];
}

-(BOOL)contains:(NSString *)StrSearchTerm on:(NSString *)StrText {
    return  [StrText rangeOfString:StrSearchTerm options:NSCaseInsensitiveSearch].location==NSNotFound?FALSE:TRUE;
}

- (IBAction)connectURL:(id)sender {
    NSURL* rUrl = nil;
    NSString* urlString = nil;
    
    if( [sender isKindOfClass:[NSString class]] ) {
        urlString = sender;
        rUrl = [NSURL URLWithString:sender];
    } else {
        urlString = [sender stringValue];
        rUrl = [NSURL URLWithString:urlString];
    }
    
    if(!rUrl.scheme) {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        rUrl = [NSURL URLWithString:modifiedURLString];
    }
    
    NSString* kMobileSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:rUrl];
    [request setValue:kMobileSafariUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [pageFavicon setHidden:YES];
    [self.progr startAnimation:sender];
    self.urlButton.intValue = 0;
    [self.url close];
    [[mobileView mainFrame] loadRequest:request];
    [[desktopView mainFrame] loadRequest:[NSMutableURLRequest requestWithURL:rUrl]];
    [textField resignFirstResponder];
}

- (IBAction)reloadURL:(id)sender {
    [[mobileView mainFrame] reload];
    [[desktopView mainFrame] reload];
}

#pragma mark -- Custom Window

- (void)setupCloseButton {
    INWindowButton *closeButton = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
    closeButton.activeImage = [NSImage imageNamed:@"close-active-color.tiff"];
    closeButton.activeNotKeyWindowImage = [NSImage imageNamed:@"close-activenokey-color.tiff"];
    closeButton.inactiveImage = [NSImage imageNamed:@"close-inactive-disabled-color.tiff"];
    closeButton.pressedImage = [NSImage imageNamed:@"close-pd-color.tiff"];
    closeButton.rolloverImage = [NSImage imageNamed:@"close-rollover-color.tiff"];
    self.window.closeButton = closeButton;
}

- (void)setupMinimizeButton {
    INWindowButton *button = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
    button.activeImage = [NSImage imageNamed:@"minimize-active-color.tiff"];
    button.activeNotKeyWindowImage = [NSImage imageNamed:@"minimize-activenokey-color.tiff"];
    button.inactiveImage = [NSImage imageNamed:@"minimize-inactive-disabled-color.tiff"];
    button.pressedImage = [NSImage imageNamed:@"minimize-pd-color.tiff"];
    button.rolloverImage = [NSImage imageNamed:@"minimize-rollover-color.tiff"];
    self.window.minimizeButton = button;
}

- (void)setupZoomButton {
    INWindowButton *button = [INWindowButton windowButtonWithSize:NSMakeSize(14, 16) groupIdentifier:nil];
    button.activeImage = [NSImage imageNamed:@"zoom-active-color.tiff"];
    button.activeNotKeyWindowImage = [NSImage imageNamed:@"zoom-activenokey-color.tiff"];
    button.inactiveImage = [NSImage imageNamed:@"zoom-inactive-disabled-color.tiff"];
    button.pressedImage = [NSImage imageNamed:@"zoom-pd-color.tiff"];
    button.rolloverImage = [NSImage imageNamed:@"zoom-rollover-color.tiff"];
    self.window.zoomButton = button;
}

#pragma mark -- NSPopOvers

- (BOOL)buttonIsPressed
{
    return self.urlButton.intValue == 1;
}

- (IBAction)showURL:(id)sender {
    if (self.buttonIsPressed) {
        [[self url] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        self.urlButton.intValue = 0;
        [self.url close];
    }
}

#pragma -- Helper/Conveience functions

- (IBAction)clearCache:(id)sender {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end