//
//  ActionSheetController.h
//  Sorter
//
//  Created by Peter Brachwitz on 24/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionSheetController : NSObject {
    IBOutlet NSPanel * actionSheet;
    IBOutlet NSView * actionDetailHolder;
    IBOutlet NSObjectController * rulesController;
    IBOutlet NSPopUpButton * actionSelector;
    NSArrayController * actionsController;
    NSObjectController * actionController;
    NSMutableArray * filteredActions;
    NSArray * availableActions;
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, retain) NSArray * availableActions;
@property (nonatomic, retain) IBOutlet NSArrayController * actionsController;
@property (nonatomic, retain) IBOutlet NSObjectController * actionController;
@property (nonatomic, readonly) IBOutlet NSManagedObjectContext *managedObjectContext;

-(IBAction) showActionSheet:(id)sender;
-(IBAction) endActionSheet:(id)sender;
-(void) didEndActionSheet:(NSWindow *) sheet returnCode: (NSInteger*) returnCode contextInfo: (void *) contextInfo;



@end
