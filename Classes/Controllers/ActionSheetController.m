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

#import "ActionSheetController.h"


@interface ActionSheetController(PrivateApi)
- (void) showDetailView:(NSView*) view;
- (void) removeDetailViews;
- (void) updateActionDetail;
- (void) prepareActionSheet;
- (void) showActionSheetWithAction: (Action*) action forWindow: (id) window;
@end


@implementation ActionSheetController
@synthesize availableActions, actionsController, actionController;

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
    [self removeDetailViews];
    Action * a = [actionController content];
    if (a != NULL) {
        NSView * v = [a settingsView];
        if(v != NULL) {
            [self showDetaiView:v];
             return;
        }
    }
}

#pragma mark - Sheet Methods

- (void) prepareActionSheet {
    if(! actionSheet) {
        NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
        NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"ActionSheet" bundle:myBundle]autorelease];
        BOOL success = [nib instantiateNibWithOwner:self topLevelObjects:nil];
        NSAssert(success, @"Failed to load Xib");
    }
    [[[self managedObjectContext] undoManager] beginUndoGrouping];
}

- (IBAction)showActionSheet:(id)sender {
    [self prepareActionSheet];
    id persistent = [actionController newObject];
    [self showActionSheetWithAction:persistent forWindow:[sender window]];
}

- (IBAction)showActionSheetWithSelection:(id)sender {
    NSArray * selection =  [actionsController selectedObjects];
    if ([selection count] == 0) {
        return;
    }
    [self prepareActionSheet];
    [self showActionSheetWithAction:[selection objectAtIndex:0] forWindow:[NSApp mainWindow]];

}

- (void) showActionSheetWithAction:(Action *)action forWindow:(id)window {
    [actionController addObject:action];
    [NSApp beginSheet:actionSheet modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndActionSheet:returnCode:contextInfo:) contextInfo:nil];
}


- (IBAction)endActionSheet:(id)sender {
    [NSApp endSheet:actionSheet]; 
    NSUndoManager * man = [[self managedObjectContext] undoManager];
    [man endUndoGrouping];
    [man undoNestedGroup];
}

- (IBAction)endActionSheetWithSuccess:(id)sender {
    [NSApp endSheet:actionSheet];
    Action * obj = [actionController content];
    if(![obj rule]){
        NSArray * selected = [rulesController selectedObjects];
        if ([selected count] == 1) {
            Rule * rule = (Rule *) [selected objectAtIndex:0];
            [obj setRule:rule];        
        }
    }
    
    [[[self managedObjectContext] undoManager] endUndoGrouping];
    [[[self managedObjectContext] undoManager] setActionName:@"Object edit"];
}


- (void) didEndActionSheet:(NSWindow *)sheet returnCode:(NSInteger *) returnCode contextInfo :(void *)contextInfo {
    [sheet makeFirstResponder:nil];
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

#pragma mark - NSWindow delegate

- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow *) window {
    return  [[self managedObjectContext] undoManager];
}






@end
