//
//  BreaksTableViewController.m
//  TwoBrowser
//
//  Created by Chris J. Davis on 1/17/14.
//  Copyright (c) 2014 LEAGUEOFBEARDS. All rights reserved.
//

#import "BreaksTableViewController.h"
#import "Breakpoint.h"

@implementation BreaksTableViewController

- (id) init {
    self = [super init];
    if( self ) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentFolder = [path objectAtIndex:0];
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/breakpoints.plist"];
        
        NSMutableArray *savedBreakpoints = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:filePath]];
        
        if( [savedBreakpoints count] > 0 ) {
            breaksArray = savedBreakpoints;
        } else {
            breaksArray = [[NSMutableArray alloc] init];
            [breaksArray writeToFile:filePath atomically:YES];
        }
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [breaksArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Breakpoint *bp = [breaksArray objectAtIndex:row];
    NSString *ident = [tableColumn identifier];
    
    return [bp valueForKey:ident];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Breakpoint *bp = [breaksArray objectAtIndex:row];
    NSString *ident = [tableColumn identifier];
    [bp setValue:object forKey:ident];
    
    [self saveBreaks];
}

- (IBAction)addBreak:(id)sender {
    [breaksArray addObject:[[Breakpoint alloc] init]];
    [breaksTable reloadData];
}

- (IBAction)removeBreak:(id)sender {
    NSInteger row = [breaksTable selectedRow];
    [breaksTable abortEditing];
    
    if( row != -1 ) {
        [breaksArray removeObjectAtIndex:row];
        [breaksTable reloadData];
        [self saveBreaks];
    }
}

-(void)saveBreaks {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/breakpoints.plist"];
    [breaksArray writeToFile:filePath atomically:YES];
}

@end
