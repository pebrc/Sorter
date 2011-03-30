//
//  PBWatcherRegistry.h
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <libkern/OSAtomic.h>
#import "PBWatcher.h"
#import "ThreadSafeMutableDictionary.h"

@interface PBWatcherRegistry : NSObject {
	ThreadSafeMutableDictionary *registeredWatchers;
}
+ (PBWatcherRegistry* ) registry;
+ (void) shutdown;

- (void) prepareForDealloc;
- (PBWatcher *) watcherForPath: (NSString *) path;
- (void) setWatcher: (PBWatcher *) watcher forPath: (NSString *) path; //not thread safe
- (void) removeWatcher: (PBWatcher*) watcher;

@end
