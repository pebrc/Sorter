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

#import <Cocoa/Cocoa.h>
#import "RulesController.h"
#import "TreeSupport.h"

@interface MainWindowController : NSWindowController {
    NSMutableArray *contents;
    IBOutlet NSTreeController * treeController;
    IBOutlet NSOutlineView		*outlineView;
    NSViewController * detailController;
    IBOutlet NSView * detailViewHolder;
    IBOutlet NSToolbarItem * addButton;
@private
    
}
@property (nonatomic, retain) NSMutableArray * contents;
-(IBAction) addRule:(id)sender;
-(IBAction) removeRule: (id)sender;
-(IBAction) applyRulesToSourceDirectories:(id) sender;
-(void) populateContents;
-(Source *) sourceWithDefaultLocation;
-(void) selectParentFromSelection;
-(void) selectFirstChildFromSelection;
-(void) showInitialHelp;
@end
