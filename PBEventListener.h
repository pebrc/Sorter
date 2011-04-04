//
//  PBEventListener.h
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PBEvent, PBWatcher;
@protocol PBEventListener

- (void) event: (PBEvent *) event reportedBy: (PBWatcher*) watcher;

- (FSEventStreamEventId) lastListened;


@end
