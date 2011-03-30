//
//  RulesController.h
//  Sorter
//
//  Created by Peter Brachwitz on 14/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Rule.h"
#import "RuleHandler.h"
#import "Transformers.h"

@interface RulesController : NSArrayController {
}
-(void) showOpenPanel:(id)sender ForKey:(NSString *)key withTransformation:(id (^)(NSURL *))block; 
-(IBAction) showSourcePanel:(id)sender;
-(IBAction) showTargetPanel:(id) sender;
-(IBAction) applyRulesToSourceDirectories:(id) sender;
//-(void) notifyChanged: (NSNotification *) notification;

@end
