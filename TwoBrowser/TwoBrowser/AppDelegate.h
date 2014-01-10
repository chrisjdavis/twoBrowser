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

@class WebView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) IBOutlet NSTextField *textField;
@property (weak) IBOutlet WebView *desktopView;
@property (weak) IBOutlet WebView *mobileView;
@property (weak) IBOutlet NSView *titleView;
@property (nonatomic, assign) IBOutlet NSSplitView *theSplits;
@property (weak) IBOutlet NSProgressIndicator *progr;
@property (weak) IBOutlet NSSegmentedControl *toggler;
@property (weak) IBOutlet NSPopUpButton *breakpoints;
@property (assign) IBOutlet NSPopover *url;
@property (weak) IBOutlet NSButton *urlButton;
@property (assign) IBOutlet NSPopover *bookmarkAdd;
@property (weak) IBOutlet NSTextField *pageTitle;
@property (weak) IBOutlet NSImageView *pageFavicon;
@property (weak) IBOutlet NSTextField *mobileWidth;
@property (weak) IBOutlet NSTextField *desktopWidth;
@property (weak) IBOutlet NSView *mobileSizeIcon;

@property (assign) IBOutlet INAppStoreWindow *window;
@property (nonatomic, retain) NSMutableArray *windowControllers;

- (IBAction)toggleControl:(id)sender;
- (IBAction)showURL:(id)sender;
- (IBAction)clearCache:(id)sender;

@end