//
//  BreaksTableViewController.h
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BreaksTableViewController : NSObject <NSTableViewDataSource> {
    @private
        IBOutlet NSTableView *breaksTable;
        NSMutableArray *breaksArray;
    }

- (IBAction)addBreak:(id)sender;
- (IBAction)removeBreak:(id)sender;

@end
