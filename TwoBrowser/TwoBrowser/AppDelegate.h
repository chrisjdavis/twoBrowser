//
//  AppDelegate.h
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/3/14.
//  Copyright (c) 2014 ___LEAGUEOFBEARDS___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "InAppStoreWindow.h"
#import "NSSplitView+Animation.h"
#import "ITProgressBar.h"

@class WebView, SplitView;

@interface AppDelegate : NSObject <NSApplicationDelegate>
    @property (nonatomic, retain) IBOutlet NSTextField *textField;
    @property (weak) IBOutlet WebView *desktopView;
    @property (weak) IBOutlet WebView *mobileView;
    @property (weak) IBOutlet NSView *titleView;
    @property (weak) IBOutlet NSView *prefsTitleView;
    @property (nonatomic, assign) IBOutlet NSSplitView *theSplits;
    @property (weak) IBOutlet NSProgressIndicator *progr;
    @property (weak) IBOutlet NSSegmentedControl *toggler;
    @property (weak) IBOutlet NSPopUpButton *breakpoints;
    @property (weak) IBOutlet NSPopUpButton *userAgents;
    @property (assign) IBOutlet NSPopover *url;
    @property (assign) IBOutlet NSPopover *mWidthPop;
    @property (assign) IBOutlet NSPopover *dWidthPop;
    @property (weak) IBOutlet NSButton *urlButton;
    @property (weak) IBOutlet NSTextField *pageTitle;
    @property (weak) IBOutlet NSImageView *pageFavicon;
    @property (weak) IBOutlet NSTextField *mobileWidth;
    @property (weak) IBOutlet NSTextField *desktopWidth;
    @property (weak) IBOutlet NSView *mobileSizeIcon;
    @property (weak) IBOutlet NSButton *mWidthSetter;
    @property (weak) IBOutlet NSButton *dWidthSetter;
    @property (weak) IBOutlet NSTextField *mWidthValue;
    @property (weak) IBOutlet NSTextField *dWidthValue;
	@property (weak) IBOutlet NSImageView *imageView;
    @property (nonatomic, retain) NSBitmapImageRep *bitmap;
    @property (nonatomic, retain) NSData *pdfData;
    @property (weak) IBOutlet NSView *accessoryView;
    @property (weak) IBOutlet NSImageView *imagePreview;
    @property (weak) IBOutlet NSButton *setBreakpoints;
    @property (weak) IBOutlet NSButton *setUserAgents;
    @property (weak) IBOutlet NSTextField *prefSection;
    @property (nonatomic, retain) NSMutableArray *defaultBreaks;
    @property (nonatomic, retain) NSMutableArray *defaultAgents;
    @property (nonatomic, retain) NSArray *savedBreakpoints;
    @property (nonatomic, retain) NSArray *savedAgents;
    @property (weak) IBOutlet NSPopUpButton *otherBrowsers;
    @property (weak) IBOutlet NSButton *shareButton;

    @property (weak) IBOutlet NSTableView *breaksTable;
    @property (weak) IBOutlet NSTableView *agentsTable;

    @property (assign) IBOutlet INAppStoreWindow *window;
    @property (assign) IBOutlet INAppStoreWindow *prefs;
    @property (assign) IBOutlet NSWindow *customSheet;

    @property (assign) IBOutlet ITProgressBar *progressBar;
    @property (assign) IBOutlet NSLayoutConstraint *heightConstraint;

    - (IBAction)toggleControl:(id)sender;
    - (IBAction)showURL:(id)sender;
    - (IBAction)setMWidth:(id)sender;
    - (IBAction)setDWidth:(id)sender;
    - (IBAction)openURL:(id)sender;
    - (IBAction)clearCache:(id)sender;
@end