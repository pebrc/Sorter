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


#import "Source.h"
#import "RuleHandler.h"
@interface Source(Internal)	
- (void) setUpWatcher;
- (void) removeWatcher;
@end

@implementation Source 

@dynamic url;
@dynamic rules;
@dynamic eventid;



-(id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    NSLog(@"self: %p", &self);
    if(self != nil) {
        [self addObserver:self forKeyPath:@"rules" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
    
}

-(void) setUrl:(NSString *)url {
    DEBUG_OUTPUT(@"Will change url to %@", url);
    [self willChangeValueForKey:@"url"];
    [self setPrimitiveValue:url forKey:@"url"];
    [self didChangeValueForKey:@"url"];
    [self setUpWatcher];
}

-(void) awakeFromFetch {
	[super awakeFromFetch];
	[self setUpWatcher];

}

-(void) awakeFromInsert {
	[super awakeFromInsert];
	[self setUpWatcher];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#if MY_DEBUG_FLAG
    NSLog(@"KVO Change notification for source %@ path %@, dict %@", [self url],keyPath, [change description]);
#endif
    
    if ([[change valueForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting) {
        return;
    }
    [self setUpWatcher];
}

- (void) setUpWatcher {
    DEBUG_OUTPUT(@"in setup: %llu", [self lastListened]);
    NSUInteger numrules = [[self rules] count];
    
    if(numrules == 0) {
        [self removeWatcher];
        return;
    }
    
    if (nil == [self url]) {
        return;
    }
    
    if (self->watcher == nil) {
		self->watcher = [PBWatcher watchPath: [[NSURL URLWithString:[self url]] path] notify:self];
        [self->watcher retain];
	}
}

-(void) removeWatcher {
    if (self->watcher != nil) {
        [PBWatcher stop:self->watcher];
        [self->watcher release];
        self->watcher = nil;
    }
}

-(void) dealloc {
    NSLog(@"in dealloc");
    [super dealloc];
}

-(void) event:(PBEvent*)event reportedBy:(PBWatcher*)watcher {
	NSURL * url = [NSURL URLWithString:[event eventPath]];
    BOOL skipSubDirs = [event eventFlags] & kFSEventStreamEventFlagMustScanSubDirs ? NO : YES;
    //TODO: kFSEventStreamEventFlagRootChanged
    DEBUG_OUTPUT(@"Before: %llu", [event eventId]);
    [self setEventid: [NSNumber numberWithUnsignedLongLong:[event eventId]]];
    DEBUG_OUTPUT(@"After %llu", [self lastListened]);
	[RuleHandler handleURL:url fromSource:self skipDirs:skipSubDirs];
}

-(FSEventStreamEventId) lastListened {
    return [[self eventid] unsignedLongLongValue];
}



@end
