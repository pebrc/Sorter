//
//  Sorter_AppDelegate.h
//  Sorter
//
//  Created by Peter Brachwitz on 08.02.11.
//  Copyright __MyCompanyName__ 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBWatcherRegistry.h"
#import "Transformers.h"

@interface Sorter_AppDelegate : NSObject 
{
    NSWindow *window;
//	NSPredicateEditor *editor;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
//@property (nonatomic,retain) IBOutlet NSPredicateEditor *editor;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

@end
