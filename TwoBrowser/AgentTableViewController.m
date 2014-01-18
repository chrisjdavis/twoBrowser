//
//  AgentTableViewController.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "AgentTableViewController.h"
#import "Agent.h"

@implementation AgentTableViewController

- (id) init {
    self = [super init];
    if( self ) {
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentFolder = [path objectAtIndex:0];
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/agents.plist"];
        
        NSMutableArray *savedAgents = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:filePath]];
        
        if( [savedAgents count] > 0 ) {
            agentsArray = savedAgents;
        } else {
            agentsArray = [[NSMutableArray alloc] init];
            [agentsArray writeToFile:filePath atomically:YES];
        }
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [agentsArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Agent *ag = [agentsArray objectAtIndex:row];
    NSString *ident = [tableColumn identifier];
    
    return [ag valueForKey:ident];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Agent *ag = [agentsArray objectAtIndex:row];
    NSString *ident = [tableColumn identifier];
    [ag setValue:object forKey:ident];
    
    [self saveAgents];
}

- (IBAction)addAgent:(id)sender {
    [agentsArray addObject:[[Agent alloc] init]];
    [agentsTable reloadData];
}

- (IBAction)removeAgent:(id)sender {
    NSInteger row = [agentsTable selectedRow];
    [agentsTable abortEditing];
    
    if( row != -1 ) {
        [agentsArray removeObjectAtIndex:row];
        [agentsTable reloadData];
        [self saveAgents];
    }
}

-(void)saveAgents {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/agents.plist"];
    [agentsArray writeToFile:filePath atomically:YES];
}

@end
