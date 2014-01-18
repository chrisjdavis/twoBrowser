//
//  AgentTableViewController.h
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgentTableViewController : NSObject <NSTableViewDataSource> {

@private
    IBOutlet NSTableView *agentsTable;
    NSMutableArray *agentsArray;

}

- (IBAction)addAgent:(id)sender;
- (IBAction)removeAgent:(id)sender;

@end
