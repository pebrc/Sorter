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

#import "MainWindowController.h"
#import "TreeNode.h"

@interface MainWindowController(PrivateApi)
-(void) insert:(Rule*)rule withParent:(Source*) parent at:(NSIndexPath*) path;
@end

@implementation MainWindowController
@synthesize contents;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    detailController = [[NSViewController alloc]initWithNibName:DETAIL_VIEW bundle:nil];
    [outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [self populateContents];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSMutableArray*) contents {
    return contents;
}

-(void)populateContents {
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSError * error = nil;
	[request setEntity:[NSEntityDescription entityForName:@"Source" inManagedObjectContext:moc]];
	NSArray *fetchedSources = [moc executeFetchRequest:request error:&error];
	if (fetchedSources != nil) {
        NSMutableArray * arr = [NSMutableArray array];
        for ( id src in fetchedSources) {
            [arr addObject:[TreeNode nodeWithModel:src]];
        }
        [self setContents:arr];
    }
    [request release];

    
}

-(IBAction) addRule:(id)sender {
    //this is really getting out of hand
    NSManagedObjectContext * moc = [[NSApp delegate]managedObjectContext];
    Rule * newRule = [NSEntityDescription insertNewObjectForEntityForName:@"Rule" inManagedObjectContext:moc];

    NSIndexPath * path = nil;
    Source * parent = nil;
    NSArray * selected = [treeController selectedObjects];
    if([selected count] == 0) {
        //no selection :: add to the end of content array
        int numElements = [contents count];
        path = [NSIndexPath indexPathWithIndex:numElements];
        //no selection but a parent source might be there already
        if(numElements > 0) {
            parent = [contents objectAtIndex:0];
        } else {
            parent = [self sourceWithDefaultLocation];
            [treeController insertObject:[TreeNode nodeWithModel:parent] atArrangedObjectIndexPath:path];
            [newRule setFrom:parent];//duplicated code already: nice!
            [self selectFirstChildFromSelection];
            return;            
        }

    } else {
        id <TreeSupport> node = [selected objectAtIndex:0]; 
        // add after last child
        if([node isLeaf] && [[node representedObject] isMemberOfClass: [Rule class]]) {
            //this is a rule get the parent
            [self selectParentFromSelection];
            parent = [(Rule *)[node representedObject] from];
        } else {
            //for some reason in the initial state a source might be selected
            //or it might be source without any rules (after deletion for example)
            parent = (Source *)[node representedObject];
        }
        path = [treeController selectionIndexPath];
        path = [path indexPathByAddingIndex:[[parent rules] count]];

    }
    [self insert:newRule withParent:parent at:path];
    
    
    
    
}

-(void) insert:(Rule *)rule withParent:(Source *)parent at:(NSIndexPath *)path {
    [rule setFrom:parent];
    [treeController insertObject:[TreeNode nodeWithModel:rule] atArrangedObjectIndexPath:path];
    
}

-(void) selectParentFromSelection {
    NSArray * selection =[treeController selectedNodes];
    if([selection count] > 0 ) {
        NSTreeNode* node = [selection objectAtIndex:0];
        NSTreeNode* parent = [node parentNode];
        if(parent) {
            [treeController setSelectionIndexPath:[parent indexPath]];
        } else {
            [treeController removeSelectionIndexPaths:[treeController selectionIndexPaths]];
        }

    }
}

-(void) selectFirstChildFromSelection {
    NSArray * nodes = [treeController selectedNodes];
    if ([nodes count] > 0) {
        NSTreeNode * parent = [nodes objectAtIndex:0];
        NSArray * children =  [parent childNodes];
        if([children count] > 0) {
            NSTreeNode * firstChild = [children objectAtIndex:0];
            [treeController setSelectionIndexPath:[firstChild indexPath]];
        }
    }
}

-(IBAction) removeRule:(id)sender {
    NSManagedObjectContext * moc = [[NSApp delegate]managedObjectContext];
    for (id<TreeSupport> node in  [treeController selectedObjects]) {
        NSManagedObject * obj = [node representedObject];
        [moc deleteObject:obj];
    };
    [treeController remove:sender]; 
    
    
}

-(IBAction) applyRulesToSourceDirectories: (id) sender {
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
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


- (Source *) sourceWithDefaultLocation {
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    Source * s = [NSEntityDescription insertNewObjectForEntityForName:@"Source" inManagedObjectContext:moc];
#ifdef MY_DEBUG_DIR
    [s setUrl:[NSString stringWithFormat: @"file://localhost%s", MACRO_VALUE(MY_DEBUG_DIR)]];
#else
    [s setUrl:NSHomeDirectory()]; 
#endif
    return s;
    
}

#pragma mark - Subview Management;

- (void) removeDetailViews {
    NSArray * detailViews = [detailViewHolder subviews];
    for (id elem in detailViews) {
        NSView * subview = elem;
        [subview removeFromSuperview];
    }
    [detailViewHolder displayIfNeeded];
    
}

- (void) showEditView {
    [detailController setRepresentedObject:[[[treeController selectedObjects] objectAtIndex:0]representedObject]];    
    NSView *v = [detailController view];    
    [detailViewHolder addSubview:v];
    [detailViewHolder displayIfNeeded];
    
}

#pragma mark - NSOutlineView delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    NSTreeNode *node = (NSTreeNode*) item;
    return [[node representedObject] isSelectable];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSArray * selection = [treeController selectedObjects];
    if ([selection count] == 1 && [[selection objectAtIndex:0] isSelectable]) {
        [self showEditView];
        return;
    }
    [self removeDetailViews];
    
}
                                                                      

@end
