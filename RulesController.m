//
//  RulesController.m
//  Sorter
//
//  Created by Peter Brachwitz on 14/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RulesController.h"


@implementation RulesController

 
- (void) showOpenPanel:(id) sender ForKey:(NSString *)key withTransformation:(id (^)(NSURL *))block {
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	NSInteger result = [panel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		NSUInteger index = [self selectionIndex];
		if (index != NSNotFound) {
			Rule * rule = (Rule *) [[self arrangedObjects] objectAtIndex:index];
			[rule setValue: block((NSURL *)[[panel URLs]objectAtIndex:0]) forKey:key];
		}
	}
	
}

- (IBAction) showSourcePanel:(id)sender {
	[self showOpenPanel:sender ForKey:@"from" withTransformation: ^(NSURL *url){
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:@"SourceLocationTransformer"];
		return [transformer reverseTransformedValue:[url absoluteString]];
	}];
}

- (IBAction) showTargetPanel:(id)sender {
	[self showOpenPanel:sender ForKey:@"to" withTransformation: ^(NSURL *url){ 
		return (id)[url absoluteString];
	}];
}

-(IBAction) applyRulesToSourceDirectories: (id) sender {
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Source" inManagedObjectContext:moc]];
	NSError *error = nil;
	NSArray *fetchedSources = [moc executeFetchRequest:request error:&error];
	if (fetchedSources != nil) {
		for (id source in fetchedSources) {
			[RuleHandler handleSource:source];
		}
	}	
	[request release];
}




@end
