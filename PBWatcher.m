//
//  PBEvents.m
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PBWatcher.h"



@interface PBWatcher (PrivateAPI) 
- (void) dispatchEvent:(PBEvent*) event;
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

+ (BOOL) stop:(PBWatcher *)watcher {
    PBWatcherRegistry *registry = [PBWatcherRegistry registry];
    [registry removeWatcher:watcher];
    return [watcher stop];
}

-(id) init {
	self = [super init];
	if (self != nil) {
		[self setLatency:2.0];
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
										  kFSEventStreamEventIdSinceNow,
										  latency, kFSEventStreamCreateFlagUseCFTypes);
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
