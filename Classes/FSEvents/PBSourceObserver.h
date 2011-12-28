//
//  PBSourceObserver.h
//  Sorter
//
//  Created by Peter Brachwitz on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSourceObserver : NSObject
{
    NSManagedObjectContext * context;
}
- (id) initWithContext: (NSManagedObjectContext *) moc;
- (void) observe: (NSSet*) sources;
- (void) stopObserving: (NSSet*) sources;
- (void) observeEventsFrom: (NSManagedObjectContext * ) moc;
- (void) handleManagedObjectContextEvent:(NSNotification *) notification;

@end
