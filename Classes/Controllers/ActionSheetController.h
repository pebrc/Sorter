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

#import <Foundation/Foundation.h>
#import "Action.h"

@interface ActionSheetController : NSObject {
    IBOutlet NSPanel * actionSheet;
    IBOutlet NSView * actionDetailHolder;
    IBOutlet NSObjectController * rulesController;
    IBOutlet NSPopUpButton * actionSelector;

    NSArrayController * actionsController;
    NSObjectController * actionController;
    NSMutableArray * filteredActions;
    NSArray * availableActions;
    BOOL isActionTypeChangeable;
}
@property (nonatomic, retain) NSArray * availableActions;
@property (nonatomic, retain) IBOutlet NSArrayController * actionsController;
@property (nonatomic, retain) IBOutlet NSObjectController * actionController;
@property (nonatomic) BOOL isActionTypeChangeable;


-(IBAction) showActionSheet:(id)sender;
-(IBAction) showActionSheetWithSelection:(id)sender;
-(IBAction) endActionSheet:(id)sender;
- (NSManagedObjectContext*) managedObjectContext;
-(void) didEndActionSheet:(NSWindow *) sheet returnCode: (NSInteger*) returnCode contextInfo: (void *) contextInfo;



@end
