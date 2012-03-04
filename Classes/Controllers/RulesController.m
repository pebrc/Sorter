//Copyright (c) 2011 Peter Brachwitz
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


#import "RulesController.h"
#import "PBMetaPresetRelativeDateRowTemplate.h"

@implementation RulesController

- (void) awakeFromNib {
    NSMutableArray * templates = [[editor rowTemplates]mutableCopy];
    NSArray * initialExpr = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"kMDItemFSCreationDate"], nil];
    PBMetaPresetRelativeDateRowTemplate * custom = [[PBMetaPresetRelativeDateRowTemplate alloc] initWithLeftExpressions:initialExpr];
    NSPredicateEditorRowTemplate * standard = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:initialExpr rightExpressionAttributeType:NSDateAttributeType modifier:NSDirectPredicateModifier operators:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt: NSEqualToPredicateOperatorType], nil] options:0];
    [templates addObject:custom];
    [templates addObject:standard];
    [editor setRowTemplates:templates];
    [templates release];
    NSArray * selected = [self selectedObjects];
    if ([selected count] == 1) {
        Rule * rule = (Rule *) [selected objectAtIndex:0];
        [editor setObjectValue:[rule predicate]];
    }
}

 
- (void) showOpenPanel:(id) sender ForKey:(NSString *)key withTransformation:(id (^)(NSURL *))block {
	NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	NSInteger result = [panel runModal];
	if (result == NSFileHandlingPanelOKButton) {
		NSArray * selected = [self selectedObjects];
		if ([selected count] == 1) {
			Rule * rule = (Rule *) [selected objectAtIndex:0];
			[rule setValue: block((NSURL *)[[panel URLs]objectAtIndex:0]) forKey:key];
		}
	}
	
}

- (IBAction) showSourcePanel:(id)sender {
	[self showOpenPanel:sender ForKey:@"from" withTransformation: ^(NSURL *url){
		NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:@"SourceLocationTransformer"];
		return [transformer reverseTransformedValue:[url absoluteString]  ];
	}];
}

- (IBAction) showTargetPanel:(id)sender {
	[self showOpenPanel:sender ForKey:@"to" withTransformation: ^(NSURL *url){ 
		return (id) [url absoluteString];
	}];
}




@end
