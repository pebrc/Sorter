//Copyright (c) 2011 Peter Brachwitz
// With some inspiration from SCEvents Copyright (c) 2009 Stuart Connolly
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

#import "PBWatcher.h"



@interface PBWatcher (PrivateAPI) 
- (void) dispatchEvent:(PBEvent*) event;
- (FSEventStreamEventId) sinceWhen;
static void _PBWatcherCallBack(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]);	
@end

@implementation PBWatcher

@synthesize pathsToWatch, latency, running, listener;

+ (PBWatcher *) watchPath:(NSString *)string notify:(id <PBEventListener>)listener {
	PBWatcherRegistry *registry = [PBWatcherRegistry registry];
	PBWatcher *watcher = [registry watcherForPath:string];
	if (!watcher) {
		watcher = [[[PBWatcher alloc]init]autorelease];
		[watcher setListener:listener];
		[watcher setPathsToWatch: [NSArray arrayWithObject:string]];
		[watcher start];
		[registry setWatcher: watcher forPath:string];		
	}
	return watcher;
}

+ (BOOL) stopWatchingPath:(NSString *)path {
    PBWatcherRegistry *registry = [PBWatcherRegistry registry];
    PBWatcher * watcher = [registry watcherForPath:path];
    if(!watcher) {
        return NO;
    }
    return [self stop:watcher];    
}

+ (BOOL) stop:(PBWatcher *)watcher {
    PBWatcherRegistry *registry = [PBWatcherRegistry registry];
    [registry removeWatcher:watcher];
    return [watcher stop];
}

-(id) init {
	self = [super init];
	if (self != nil) {
        double lat = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latency"];
		[self setLatency:lat];
	}
	return self;
}

-(void) dealloc {
	if (running) {
		[self stop];
	}
	[pathsToWatch release];
	pathsToWatch = nil;
	[super dealloc];
}

- (BOOL) start {
		FSEventStreamContext context;
		context.version = 0;
		context.info    = (void*)self;
		context.retain  = NULL;
		context.release = NULL;	
		context.copyDescription = NULL;
		eventStream = FSEventStreamCreate(kCFAllocatorDefault, 
										  &_PBWatcherCallBack,
										  &context, 
										  (CFArrayRef)pathsToWatch, 
										  [self sinceWhen],
										  latency, kFSEventStreamCreateFlagUseCFTypes|kFSEventStreamCreateFlagIgnoreSelf);
	if(eventStream) {
		FSEventStreamScheduleWithRunLoop(eventStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
		
		FSEventStreamStart(eventStream);
		DEBUG_OUTPUT(@"Started fsevent watching for %@", [pathsToWatch description]);
		running = YES;
		
		return YES;
	}
	return NO;
}

- (BOOL) stop {
	if (![self isRunning]) {
		return NO;
	}
	FSEventStreamStop(eventStream);
    FSEventStreamInvalidate(eventStream);

	
	if (eventStream) FSEventStreamRelease(eventStream), eventStream = nil;
	running = NO;
    DEBUG_OUTPUT(@"STOPped fsevent watching for %@", [pathsToWatch description]);
	return YES;
}

- (BOOL) watches:(NSString *)path {
    if (![self isRunning]) {
        return NO;
    }
   return [[self pathsToWatch] containsObject:path];
}

- (void) dispatchEvent:(PBEvent *)event {
	[[self listener] event:event reportedBy:self ];
}

- (FSEventStreamEventId) sinceWhen {
    BOOL lookback = [[NSUserDefaults standardUserDefaults] boolForKey:@"useLastListened" ];
    if (lookback) {
        FSEventStreamEventId eventid = [[self listener] lastListened];
        if (eventid) {
            return eventid;
        }
    }
    return kFSEventStreamEventIdSinceNow;
}

static void _PBWatcherCallBack(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]){
	PBWatcher *callbackInfo = (PBWatcher *) clientCallBackInfo;

	
	for (int i = 0; i< numEvents; i++) {
		PBEvent *event = [[[PBEvent alloc] initWithId:(FSEventStreamEventId) eventIds[i]
												 date:[NSDate date]
												 path:[((NSArray *)eventPaths) objectAtIndex:i]
										   eventFlags: (FSEventStreamEventFlags)eventFlags[i]] autorelease];
		[callbackInfo dispatchEvent:event];
		event = nil;
	}
};
@end
