//
//  PBWatcherRegistry.m
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBWatcherRegistry.h"


@implementation PBWatcherRegistry
	static void * volatile singleton = nil;

+(PBWatcherRegistry*) registry {
	
	while (!singleton) {
		PBWatcherRegistry * tmp = [[self alloc]init];
		if (!OSAtomicCompareAndSwapPtrBarrier(0x0, tmp, &singleton)) {
			[tmp release];
		}
	}
	DEBUG_OUTPUT(@"Registry class: %@", [(id)singleton class]);
	DEBUG_OUTPUT(@"Registry address: %p", &singleton);

	return singleton;
}

+ (void) shutdown {
	[[self registry] prepareForDealloc];
}




- (id) init {
	self = [super init];
	if (self != nil) {
		registeredWatchers = [ThreadSafeMutableDictionary dictionary];
		[registeredWatchers retain];
	}
	return self;
}

- (void) prepareForDealloc {
	NSString *key;
	for (key in registeredWatchers) {
		[[registeredWatchers objectForKey:key] release];
	}
	[registeredWatchers release]; registeredWatchers = nil;
	
}

- (void) dealloc {
	[self prepareForDealloc];
	[super dealloc];
}

/*soft Singleton implementation*/

- (id) copyWithZone: (NSZone*) zone {
	return self;
}

- (id) retain {
	return self;
}
 
- (NSUInteger) retainCount {
	return NSUIntegerMax;
}

- (void) release {
	//nothing to do;
}

- (id) autorelease {
	return self;
}

- (PBWatcher *) watcherForPath:(NSString *)path {
	DEBUG_OUTPUT(@"Reg data store class: %@", [registeredWatchers class]);
	DEBUG_OUTPUT(@"Reg data store address: %p", &registeredWatchers);
	DEBUG_OUTPUT(@"Reg data store contents: %@", [registeredWatchers description]);
	return 	[registeredWatchers objectForKey: path];
}
- (void) setWatcher: (PBWatcher *) watcher forPath: (NSString *) path {
	return [registeredWatchers setObject:watcher forKey:path];
}

- (void) removeWatcher:(PBWatcher *)watcher {
    NSArray * paths = [watcher pathsToWatch];
    for (id path in paths) {
        [registeredWatchers removeObjectForKey:path];
    }
}

@end
