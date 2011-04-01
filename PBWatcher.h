//
//  PBEvents.h
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>
#import "PBEventListener.h"
#import "PBEvent.h"
#import "PBWatcherRegistry.h"


@interface PBWatcher : NSObject {
	NSArray *pathsToWatch;
	FSEventStreamRef eventStream;
	CFAbsoluteTime latency;
	id < PBEventListener > listener;
	BOOL running;
}
@property (retain, readwrite) NSArray * pathsToWatch;
@property (assign, readwrite) double latency;
@property (retain, readwrite) id < PBEventListener > listener;
@property (readonly,getter=isRunning) BOOL running;
+(PBWatcher *) watchPath: (NSString *) string notify: (id < PBEventListener >) listener;
+(BOOL) stop: (PBWatcher *) watcher;

-(BOOL) start;
-(BOOL) stop;

-(BOOL) watches:(NSString *) path;
@end
