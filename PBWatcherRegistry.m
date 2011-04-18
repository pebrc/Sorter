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
	[registeredWatchers removeAllObjects];
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
