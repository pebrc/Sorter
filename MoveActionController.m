//
//  MoveActionController.m
//  Sorter
//
//  Created by Peter Brachwitz on 03/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoveActionController.h"

@implementation MoveActionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (IBAction) showOpenPanel:(id) sender {
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	NSInteger result = [panel runModal];
	if (result == NSFileHandlingPanelOKButton) {
        [[self representedObject]setTarget:[[panel URLs]objectAtIndex:0]];
	}
	
}

@end
