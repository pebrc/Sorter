// 
//  Source.m
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Source.h"
#import "RuleHandler.h"
@interface Source(Internal)	
- (void) setUpWatcher;
- (void) removeWatcher;
@end

@implementation Source 

@dynamic url;
@dynamic rules;



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
    NSLog(@"Change notification for source %@ path %@, dict %@", [self url],keyPath, [change description]);
#endif
    
    if ([[change valueForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting) {
        return;
    }
    [self setUpWatcher];
}

- (void) setUpWatcher {
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
//	[[NSNotificationCenter defaultCenter] postNotificationName:PBEventName object:event];
	NSURL * url = [NSURL URLWithString:[event eventPath]];
	[RuleHandler handleURL:url fromSource:self skipDirs:YES];
}

@end
