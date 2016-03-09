//
//  AppDelegate.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/3/14.
//  Copyright (c) 2014 ___LEAGUEOFBEARDS___. All rights reserved.
//

#import "AppDelegate.h"
#import "INWindowButton.h"

@interface WebInspector : NSObject  { WebView *_webView; }
    - (id)initWithWebView:(WebView *)webView;
    - (void)detach:     (id)sender;
    - (void)show:       (id)sender;
    - (void)showConsole:(id)sender;
    - (void)hideConsole:(id)sender;
@end

@interface AppDelegate() <NSSplitViewDelegate>

- (IBAction)connectURL:(id)sender;
- (IBAction)reloadURL:(id)sender;

@end;

NSViewController *webViewController;

@implementation AppDelegate  { WebInspector *_inspector; }

@synthesize window;
@synthesize prefs;
@synthesize customSheet;
@synthesize textField;
@synthesize prefsTitleView;
@synthesize mobileView;
@synthesize desktopView;
@synthesize theSplits = theSplits_;
@synthesize toggler;
@synthesize breakpoints;
@synthesize userAgents;
@synthesize mWidthPop;
@synthesize urlButton;
@synthesize pageTitle;
@synthesize pageFavicon;
@synthesize desktopWidth;
@synthesize mobileWidth;
@synthesize mobileSizeIcon;
@synthesize mWidthSetter;
@synthesize dWidthSetter;
@synthesize mWidthValue;
@synthesize dWidthValue;
@synthesize bitmap;
@synthesize pdfData;
@synthesize imageView;
@synthesize imagePreview;
@synthesize accessoryView;
@synthesize prefSection;
@synthesize setBreakpoints;
@synthesize setUserAgents;
@synthesize defaultBreaks;
@synthesize savedBreakpoints;
@synthesize savedAgents;
@synthesize defaultAgents;
@synthesize breaksTable;
@synthesize agentsTable;
@synthesize progressBar;
@synthesize otherBrowsers;
@synthesize shareButton;

NSMetadataQuery *metadataQuery = nil;
NSArray *browsers = nil;

- (id)init {
    [self checkPlists];
    return self;
}

- (void) awakeFromNib {
    [self loadWelcome];
    NSAppleEventManager *eventManager = [NSAppleEventManager sharedAppleEventManager];
    [eventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    [CATransaction begin]; {
        [progressBar setHidden:TRUE];
    }[CATransaction commit];
}

- (void)checkPlists {
    NSArray *namesArray = [NSArray arrayWithObjects:@"320", @"360", @"768", @"800", @"980", nil];
    NSArray *widthsArray = [NSArray arrayWithObjects:@"320", @"360", @"768", @"800", @"980", nil];
    
    NSArray *agentNamesArray = [NSArray arrayWithObjects:@"iPhone",
                                @"Android Chrome",
                                @"Blackberry Mobile",
                                @"Windows Phone",
                                nil];
    
    NSArray *agentStringArray = [NSArray arrayWithObjects:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7",
                                 @"Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
                                 @"Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+",
                                 @"Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)",
                                 nil];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/breakpoints.plist"];
    NSString *agentsFilePath = [documentFolder stringByAppendingFormat:@"/agents.plist"];
    
    savedBreakpoints = [NSArray arrayWithContentsOfFile:filePath];
    savedAgents = [NSArray arrayWithContentsOfFile:agentsFilePath];
    
    if ([savedBreakpoints count] == 0) {
        self.defaultBreaks = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [namesArray count]; i++) {
            NSMutableDictionary *objectDict = [NSMutableDictionary dictionary];
            NSString *name = (NSString *)[namesArray objectAtIndex:i];
            NSString *width = (NSString *)[widthsArray objectAtIndex:i];
            [objectDict setObject:name forKey:@"name"];
            [objectDict setObject:width forKey:@"width"];
            [defaultBreaks insertObject:objectDict atIndex:i];
        }
        
        [defaultBreaks writeToFile:filePath atomically:YES];
    }
    
    if ([savedAgents count] == 0) {
        self.defaultAgents = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [agentNamesArray count]; i++) {
            NSMutableDictionary *objectDict = [NSMutableDictionary dictionary];
            NSString *name = (NSString *)[agentNamesArray objectAtIndex:i];
            NSString *agent = (NSString *)[agentStringArray objectAtIndex:i];
            [objectDict setObject:name forKey:@"name"];
            [objectDict setObject:agent forKey:@"agentString"];
            [defaultAgents insertObject:objectDict atIndex:i];
        }
        
        [defaultAgents writeToFile:agentsFilePath atomically:YES];
    }
    
    [breakpoints removeAllItems];
    
    for (int i = 0; i < [defaultBreaks count]; ) {
        NSDictionary *row = [defaultBreaks objectAtIndex:i];
        [breakpoints addItemWithTitle:[row objectForKey:@"name"]];
        i++;
    }
    
    [userAgents removeAllItems];
    
    for (int i = 0; i < [defaultAgents count]; ) {
        NSDictionary *row = [defaultAgents objectAtIndex:i];
        [userAgents addItemWithTitle:[row objectForKey:@"name"]];
        i++;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setUpExternalBrowsers];
    // setup some cache defaults.
    int cacheSizeMemory = 4*1024*1024; // 4MB
    int cacheSizeDisk = 32*1024*1024; // 32MB
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSAppleEventManager *eventManager = [NSAppleEventManager sharedAppleEventManager];
    [eventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    self.window.trafficLightButtonsLeftMargin = 9.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.centerFullScreenButton = YES;
    self.window.titleBarHeight = 40.0;
    self.titleView.frame = self.window.titleBarView.bounds;
    self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.titleBarView addSubview:self.titleView];
    self.window.title = @"Two";
    self.window.showsTitle = NO;
    
    [theSplits_ setPosition:320 - 3 ofDividerAtIndex:0];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];

    NSString *filePath = [documentFolder stringByAppendingFormat:@"/breakpoints.plist"];
    NSString *agentsFilePath = [documentFolder stringByAppendingFormat:@"/agents.plist"];
    
    savedBreakpoints = [NSArray arrayWithContentsOfFile:filePath];
    savedAgents = [NSArray arrayWithContentsOfFile:agentsFilePath];
    
    [breakpoints removeAllItems];
    
    for (int i = 0; i < [savedBreakpoints count]; i++ ) {
        NSDictionary *row = [savedBreakpoints objectAtIndex:i];
        [breakpoints addItemWithTitle:[row objectForKey:@"name"]];
    }
    
    [userAgents removeAllItems];

    for (int i = 0; i < [savedAgents count]; i++ ) {
        NSDictionary *row = [savedAgents objectAtIndex:i];
        [userAgents addItemWithTitle:[row objectForKey:@"name"]];
    }
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStartLoad:)name:WebViewProgressStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewFinishedLoading:)name:WebViewProgressFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize:)name:NSSplitViewDidResizeSubviewsNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidReceiveNotification:) name:NSMetadataQueryDidUpdateNotification object:metadataQuery];
    
    [theSplits_ setDelegate:self];
    [mobileView setPolicyDelegate:self];
    [desktopView setPolicyDelegate:self];
}

#pragma mark -- User Info Saving Times

- (void)handleBreakpointsSave:(NSArray *)breaks {
    NSMutableArray *retArray = [[NSMutableArray alloc] initWithArray:((NSMutableArray *) [[NSUserDefaults standardUserDefaults] objectForKey:@"userBreakpoints"])];
    NSLog(@"%@", retArray);
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *prefixToRemove = @"two://";
    NSString *filePrefix = @"file///";
    NSString *tmpString = nil;
    NSString *newString = nil;
    
    if ([urlString hasPrefix:prefixToRemove]) {
        tmpString = [urlString substringFromIndex:[prefixToRemove length]];
        
        if ([tmpString hasPrefix:filePrefix]) {
            tmpString = [tmpString substringFromIndex:[filePrefix length]];
            tmpString = [NSString stringWithFormat:@"file:///%@", tmpString];
            [self connectURL:tmpString];
        } else {
            newString = tmpString;
            [self connectURL:newString];
        }
    }
}

#pragma mark -- respsonsive breakpoints

- (IBAction)chooseBreakpoint:(id)sender {
    NSDictionary *width = [savedBreakpoints objectAtIndex:breakpoints.indexOfSelectedItem];
    NSString *size = [width objectForKey:@"width"];

    [mobileView setHidden:NO];
    [theSplits_ animateView:0 toDimension:size.intValue - 3];
        
    toggler.selectedSegment = 0;
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    [theSplits_ adjustSubviews];
}

#pragma mark -- Select a UA

- (IBAction)chooseUA:(id)sender {
    NSURL *rUrl = [NSURL URLWithString:[mobileView mainFrameURL]];
    NSDictionary *agent = [savedAgents objectAtIndex:userAgents.indexOfSelectedItem];
    NSString* ua = [agent objectForKey:@"agentString"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:rUrl];
    
    [mobileView setCustomUserAgent:ua];

    [CATransaction begin]; {
        [progressBar setHidden:FALSE];
    }[CATransaction commit];
    
    [[mobileView mainFrame] loadRequest:request];
}

#pragma mark -- SplitVIiew crap

- (IBAction)toggleControl:(id)sender {
    switch ((((NSSegmentedControl *)sender).selectedSegment)) {
        case 0:
            [theSplits_ setPosition:1 ofDividerAtIndex:0];
            [theSplits_ animateView:0 toDimension:320 + 0];
            [theSplits_ adjustSubviews];
            [mobileView setHidden:NO];
            [mobileWidth setHidden:NO];
            [mobileSizeIcon setHidden:NO];
            break;
        case 1:
            [mobileView setHidden:YES];
            [mobileWidth setHidden:YES];
            [mobileSizeIcon setHidden:YES];
            [theSplits_ animateView:0 toDimension:0];
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

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    NSView *m = [[splitView subviews] objectAtIndex:0];
    NSView *d = [[splitView subviews] objectAtIndex:1];
    
    if ( subview == d ) {
        return YES;
    } else if( subview == m ) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -- webKit Specific

- (void)loadWelcome {
    NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
    NSURLRequest *localRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:localFilePath]];
    [[mobileView mainFrame] loadRequest:localRequest];
    [[desktopView mainFrame] loadRequest:localRequest];
}

- (void)webViewDidStartLoad:(NSNotification *)notification {
    [CATransaction begin]; {
        [progressBar setHidden:FALSE];
    }[CATransaction commit];
}

- (void)webViewFinishedLoading:(NSNotification *)notification {
    [CATransaction begin]; {
        [progressBar setHidden:TRUE];
    }[CATransaction commit];
    
    NSString * TitleString = [NSString stringWithFormat:@"Testing %@", [[notification object] mainFrameTitle]];
    NSString * newURLString = [NSString stringWithFormat:@"%@", [[notification object] mainFrameURL]];
    
    
    if( [self contains:@"file://" on:newURLString] == false ) {
        [textField setStringValue:newURLString];
    }
    
    [pageTitle setStringValue:TitleString];
    [pageFavicon setImage:[[notification object] mainFrameIcon]];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSNumber *navType = [actionInformation objectForKey: @"WebActionNavigationTypeKey"];
    
    if( sender == mobileView && [navType isEqualToNumber:[NSNumber numberWithInt:0]] ) {
        [[desktopView mainFrame] loadRequest:request];
    } else if( sender == desktopView && [navType isEqualToNumber:[NSNumber numberWithInt:0]] ) {
        [[mobileView mainFrame] loadRequest:request];
    }
    
    [listener use];
}

- (IBAction)showInspector:(id)x {
    _inspector = [WebInspector.alloc initWithWebView:mobileView];
        [_inspector detach:mobileView];
        [_inspector showConsole:mobileView];
   
    _inspector = [WebInspector.alloc initWithWebView:desktopView];
        [_inspector detach:desktopView];
        [_inspector showConsole:desktopView];
}

-(BOOL)contains:(NSString *)StrSearchTerm on:(NSString *)StrText {
    return  [StrText rangeOfString:StrSearchTerm options:NSCaseInsensitiveSearch].location == NSNotFound ? FALSE : TRUE;
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
    
    if( [self contains:@"http://" on:urlString] == false && [self contains:@"https://" on:urlString] == false ) {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        rUrl = [NSURL URLWithString:modifiedURLString];
    }
    
    NSString* kMobileSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:rUrl];
    
    [mobileView setCustomUserAgent:kMobileSafariUserAgent];
    
    [CATransaction begin]; {
        [progressBar setHidden:FALSE];
    }[CATransaction commit];
    
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

- (BOOL)buttonIsPressed:(NSButton *)sender {
    return sender.intValue == 1;
}

- (IBAction)setMWidth:(id)sender {
    if( [self buttonIsPressed:mWidthSetter] ) {
         NSRect leftFrame = [mobileView frame];
        [mWidthValue setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
        [[self mWidthPop] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        self.mWidthSetter.intValue = 0;
        [self.mWidthPop close];
    }
}

- (IBAction)setDWidth:(id)sender {
//    if( [self buttonIsPressed:dWidthSetter] ) {
//        NSRect leftFrame = [desktopView frame];
//        [dWidthValue setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
//        [[self dWidthPop] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
//    } else {
//        self.dWidthSetter.intValue = 0;
//        [self.dWidthPop close];
//    }
}

- (IBAction)showURL:(id)sender {
    if( [self buttonIsPressed:urlButton] ) {
        [[self url] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        self.urlButton.intValue = 0;
        [self.url close];
    }
}

- (IBAction)openURL:(id)sender {
    [textField selectText:self];
//    [[self url] showRelativeToRect:[urlButton bounds] ofView:urlButton preferredEdge:NSMaxYEdge];
}

- (IBAction)manualChangeM:(id)sender {
    [mobileView setHidden:NO];
    [theSplits_ animateView:0 toDimension:[sender integerValue] - 3];
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    self.mWidthSetter.intValue = 0;
    [self.mWidthPop close];
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    [theSplits_ adjustSubviews];
}

- (IBAction)manualChangeD:(id)sender {
    [mobileView setHidden:NO];
    [theSplits_ animateView:1 toDimension:[sender integerValue] - 3];
    
    NSRect leftFrame = [mobileView frame];
    NSRect rightFrame = [desktopView frame];
    
    self.mWidthSetter.intValue = 0;
    [self.mWidthPop close];
    
    [mobileWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(leftFrame.size.width)]];
    [desktopWidth setStringValue:[NSString stringWithFormat: @"%.f", floor(rightFrame.size.width)]];
    [theSplits_ adjustSubviews];
}

#pragma -- Helper/Conveience functions

- (IBAction)clearCache:(id)sender {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (IBAction)getImageFromWeb:(id)sender {
    CGSize contentSize = CGSizeMake([[mobileView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue],
                                    [[mobileView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue]);

    NSView *viewport = [[[mobileView mainFrame] frameView] documentView]; // width/height of html page
	NSRect viewportBounds = [viewport bounds];
    NSRect frame = NSMakeRect(0.0, 0.0, contentSize.width, contentSize.height);
    
    NSWindow *hiddenWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect( -1000,-1000, contentSize.width, contentSize.height ) styleMask: NSTitledWindowMask | NSClosableWindowMask backing:NSBackingStoreNonretained defer:NO];
    WebView *hiddenWebView = [[WebView alloc] initWithFrame:frame frameName:@"Hidden.Frame" groupName:nil];

    NSString *hURL = [textField stringValue];
    [hiddenWindow setContentView:hiddenWebView];
    
    [[hiddenWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:hURL]]];
    [hiddenWebView lockFocus];
    
    while ([hiddenWebView isLoading]) {
        [hiddenWebView setNeedsDisplay:NO];
        [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate dateWithTimeIntervalSinceNow:1.0] inMode:NSDefaultRunLoopMode dequeue:YES];
    }
    
    [hiddenWebView setNeedsDisplay:YES];
    
    bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:viewportBounds];
    
    [hiddenWebView unlockFocus];
    
    NSImage *dispImage = [[NSImage alloc] initWithData:[bitmap TIFFRepresentation]];
	// Display the image
	[imagePreview setImage:dispImage];
    
    float payload = 1;
    
    [shareButton sendActionOn:NSLeftMouseDownMask];
    
    [NSApp beginSheet:customSheet modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:(void *)[NSNumber numberWithFloat:payload]];
}

- (IBAction)saveImage:(id)sender {
    NSSavePanel *save = [NSSavePanel savePanel];
    
    NSMutableString *filenameString = [NSMutableString stringWithFormat:@"%@", [mobileView mainFrameTitle]];
    
    [filenameString replaceOccurrencesOfString:@" - " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [filenameString length])];
    [filenameString replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [filenameString length])];
    [filenameString replaceOccurrencesOfString:@"," withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [filenameString length])];
    
    [save setAllowedFileTypes: [NSArray arrayWithObject: @"png"]];
	[save setNameFieldStringValue:filenameString];
    
    NSUInteger result;
    
    result = [save runModal];
    
    if (result == NSOKButton) {
        NSString *selectedFile = [save filename];
        NSString *savePath = selectedFile;
        
        if( [self contains:@".png" on:savePath] == false ) {
            savePath = [NSString stringWithFormat:@"%@.%@", savePath, @"png"];
        }
       
        [[bitmap representationUsingType:NSPNGFileType properties:nil] writeToFile:savePath atomically:YES];
        [customSheet orderOut:self];
        [NSApp endSheet:customSheet returnCode:([sender tag] == 1) ? NSOKButton : NSCancelButton];
    }
}

- (IBAction)closeMyPanel:(id)sender {
    [customSheet orderOut:self];
    [NSApp endSheet:customSheet returnCode:([sender tag] == 1) ? NSOKButton : NSCancelButton];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSCancelButton) return;
}

- (IBAction)breaksChosen:(id)sender {
    [prefSection setStringValue:@"Breakpoints"];
    [setBreakpoints setImage:[NSImage imageNamed:@"ruler.on"]];
}

- (IBAction)userAgentsChosen:(id)sender {
    [prefSection setStringValue:@"User Agents"];
    [setBreakpoints setImage:[NSImage imageNamed:@"length-512"]];
}

- (void)checkIfCloudAvaliable {
    NSURL *ubiquityContainerURL = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];

    if (ubiquityContainerURL == nil) {
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: NSLocalizedString(@"iCloud does not appear to be configured.", @""), NSLocalizedFailureReasonErrorKey, nil];
//        NSError *error = [NSError errorWithDomain:@"Application" code:404 userInfo:dict];
        return;
    }
}

-(IBAction) saveToiCould:(id)sender {
    NSURL *ubiquitousURL = nil;
    
    [self checkIfCloudAvaliable];
    
    ubiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
    NSString *theDesktopPath = [paths objectAtIndex:0];
    
    NSMutableString *filename = [NSMutableString stringWithFormat:@"%@", [mobileView mainFrameTitle]];
    
    [filename replaceOccurrencesOfString:@" - " withString:@"." options:NSLiteralSearch range:NSMakeRange(0, [filename length])];
    [filename replaceOccurrencesOfString:@" " withString:@"." options:NSLiteralSearch range:NSMakeRange(0, [filename length])];
    NSString *savePath = [NSString stringWithFormat:@"%@/%@.%@", theDesktopPath, filename, @"png"];
    
    [[bitmap representationUsingType:NSPNGFileType properties:nil] writeToFile:savePath atomically:YES];
    
    metadataQuery = [[NSMetadataQuery alloc] init];
    [metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*'", NSMetadataItemFSNameKey]];
    [metadataQuery startQuery];
    
    NSURL *destinationURL = [ubiquitousURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", @"Documents", filename, @"png"]];
    NSURL *localURL = [NSURL URLWithString:[savePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void) {
        NSError *uploadError = nil;
        NSError *removalError = nil;
        
        BOOL success = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:localURL destinationURL:destinationURL error:&uploadError];
        if (success) {
            [[NSFileManager defaultManager] removeItemAtPath:savePath error:&removalError];
            [customSheet orderOut:self];
            [NSApp endSheet:customSheet returnCode:([sender tag] == 1) ? NSOKButton : NSCancelButton];
        } else {
            NSLog(@"%@", uploadError);
        }
    });
}

- (void)queryDidReceiveNotification:(NSNotification *)notification {
    NSArray *results = [metadataQuery results];
    for(NSMetadataItem *item in results) {
        NSString *filename = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        NSNumber *filesize = [item valueForAttribute:NSMetadataItemFSSizeKey];
        NSDate *updated = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSLog(@"%@ (%@ bytes, updated %@)", filename, filesize, updated);
    }
}

- (void)setUpExternalBrowsers {
    browsers = CFBridgingRelease(LSCopyAllHandlersForURLScheme(CFSTR("https")));
    NSFileManager *fileManager	= [NSFileManager defaultManager];
    
    for (int i = 0; i < [browsers count]; i++ ) {
        NSDictionary *row = [browsers objectAtIndex:i];

        NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[NSString stringWithFormat:@"%@", row]];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSString *appName = [[path componentsSeparatedByString:@"/"] lastObject];
            NSString *name = [appName stringByReplacingOccurrencesOfString:@".app" withString:@""];
            [otherBrowsers addItemWithTitle:name];
        }
    }
}

- (IBAction)chooseExternalBrowser:(id)sender {
    NSDictionary *name = [browsers objectAtIndex:otherBrowsers.indexOfSelectedItem - 1];
    NSString *appid = [NSString stringWithFormat:@"%@", name];
    
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSURL *nUrl = [NSURL URLWithString:[textField stringValue]];
    NSArray *urlArray = [NSArray arrayWithObjects:nUrl,nil];
    
    [ws openURLs: urlArray withAppBundleIdentifier:appid options: NSWorkspaceLaunchDefault additionalEventParamDescriptor: NULL launchIdentifiers: NULL];
}

@end