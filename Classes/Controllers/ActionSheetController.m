//
//  ActionSheetController.m
//  Sorter
//
//  Created by Peter Brachwitz on 24/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionSheetController.h"
#import "Action.h"
@interface ActionSheetController(PrivateApi)
- (void) showDetailView:(NSView*) view;
- (void) removeDetailViews;
- (void) updateActionDetail;
@end


@implementation ActionSheetController
@synthesize availableActions, actionsController, managedObjectContext, actionController;

- (id)init
{
    self = [super init];
    if (self) {

        NSSet * actions = [Action availableActions];
        NSMutableArray * result = [NSMutableArray arrayWithCapacity:[actions count]];
        for(id clazz in actions) {
            [result addObject:[[clazz alloc]init]];
        }
        availableActions = [result retain];        
        filteredActions = [[NSMutableArray arrayWithCapacity:[availableActions count]] retain];
        
    }
    
    return self;
}

- (void) awakeFromNib {
    [actionController addObserver:self forKeyPath:@"content.strategy" options:NSKeyValueObservingOptionNew context:NULL];
    [actionsController addObserver:self forKeyPath:@"arrangedObjects" options:(NSKeyValueObservingOptionNew |NSKeyValueObservingOptionInitial) context:NULL];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"content.strategy"] && [[change valueForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting) {
        [self updateActionDetail];
    } 
    
    if (([keyPath isEqualToString:@"arrangedObjects"] )) {
        [self setAvailableActions:availableActions];
    }
}



#pragma mark - Subview Management;

- (void) removeDetailViews {
    NSArray * detailViews = [actionDetailHolder subviews];
    for (id elem in detailViews) {
        NSView * subview = elem;
        [subview removeFromSuperview];
    }
    [actionDetailHolder displayIfNeeded];
    
}

- (void) showDetaiView:(NSView *) view {
    [actionDetailHolder addSubview:view];
    [actionDetailHolder displayIfNeeded];
    
}


- (void) updateActionDetail {
    Action * a = [actionController content];
    if (a != NULL) {
        NSView * v = [a settingsView];
        if(v != NULL) {
            [self showDetaiView:v];
             return;
        }
    }
    [self removeDetailViews];
    
}

#pragma mark - Sheet Methods
- (IBAction)showActionSheet:(id)sender {
    if(! actionSheet) {
        NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
        NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"ActionSheet" bundle:myBundle]autorelease];
        BOOL success = [nib instantiateNibWithOwner:self topLevelObjects:nil];
        NSAssert(success, @"Failed to load Xib");
    }
    id persistent = [actionController newObject];
    [actionController addObject:persistent];
    NSButton * b = sender;
    [NSApp beginSheet:actionSheet modalForWindow:[b window] modalDelegate:self didEndSelector:@selector(didEndActionSheet:returnCode:contextInfo:) contextInfo:b];
}

- (IBAction)endActionSheet:(id)sender {
    [NSApp endSheet:actionSheet];
    Action * obj = [actionController content];
    [actionController removeObject:obj];
    [managedObjectContext deleteObject:obj];
}

- (IBAction)endActionSheetWithSuccess:(id)sender {
    [NSApp endSheet:actionSheet];
    Action * obj = [actionController content];
    NSArray * selected = [rulesController selectedObjects];
    if ([selected count] == 1) {
        Rule * rule = (Rule *) [selected objectAtIndex:0];
        [obj setRule:rule];        
    }
}

- (void) didEndActionSheet:(NSWindow *)sheet returnCode:(NSInteger *) returnCode contextInfo :(void *)contextInfo {
    [sheet orderOut:self];
}

- (NSManagedObjectContext *) managedObjectContext {
    return [[NSApp delegate] managedObjectContext];
}

- (NSArray*) availableActions {
    return filteredActions;
}

- (void) setAvailableActions:(NSArray *)available {
    [filteredActions removeAllObjects];
    [filteredActions addObjectsFromArray:available];
    NSPredicate * pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        for (id a in [actionsController arrangedObjects]) {  
            NSObject<ActionStrategy> * strat = (NSObject<ActionStrategy> *) [a strategy];
            if ([strat class] == [evaluatedObject class]) {
                return false;
            }
        }
        return true;
    }];
    [filteredActions filterUsingPredicate:pred];

}




@end
