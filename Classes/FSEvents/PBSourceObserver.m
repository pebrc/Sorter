//Copyright (c) 2012 Peter Brachwitz
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

#import "PBSourceObserver.h"
#import "Source.h"
#import "NSManagedObjectContext+PBCoreDataSugar.h"


@interface PBSourceObserver(PrivateAPI)
-(void) setupObservationFor: (Source*) source;
-(void) stopObservationFor: (Source *) source;
-(void) setupFSWatcherFor: (Source*) source;
-(void) removeFSWatcherFor: (Source*) source;
-(void) handleObjectsOf:(Class ) clazz inSet:(NSSet *) set withBlock: (void (^)(NSSet *))blk;
@end

@implementation PBSourceObserver

- (id) initWithContext:(NSManagedObjectContext *)moc {
    self = [super init];
    if(self) {
        [self observeEventsFrom:moc];
    }
    return self;
}


- (void) dealloc {
	NSArray *fetchedSources = [context fetchAll:@"Source"];
	if (fetchedSources != nil) {
        [self stopObserving:[NSSet setWithArray:fetchedSources]];
	}
    [context release]; context = nil;
	[super dealloc];
}


-(void) observe:(NSSet *)sources {
    for (id source in sources) {
        [self setupObservationFor:source];
    }
}

-(void) stopObserving:(NSSet *)sources {
    for (id source in sources) {
        [self stopObservationFor:source];
    }
}


-(void) setupObservationFor:(Source *)source {
    [self setupFSWatcherFor:source];   
    [source addObserver:self forKeyPath:@"rules" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    [source addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void) stopObservationFor:(Source *)source {
    [self removeFSWatcherFor:source];
    [source removeObserver:self forKeyPath:@"rules" context:NULL];
    [source removeObserver:self forKeyPath:@"url" context:NULL];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    #if MY_DEBUG_FLAG
    NSLog(@"KVO Change notification for source %@ path %@, dict %@", [object url],keyPath, [change description]);
    #endif
    
    if ([[change valueForKey:NSKeyValueChangeKindKey] intValue] != NSKeyValueChangeSetting && [keyPath isEqualToString:@"rules"]) {
        return;
    }
    [self setupFSWatcherFor:object];
}



-(void) observeEventsFrom:(NSManagedObjectContext *)moc {
    context = moc;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleManagedObjectContextEvent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:moc];
       
	NSArray *fetchedSources = [moc fetchAll:@"Source"];
	if (fetchedSources != nil) {
        [self observe:[NSSet setWithArray:fetchedSources]];
	}
}


-(void) setupFSWatcherFor:(Source *)source {
    DEBUG_OUTPUT(@"in setup: %llu", [source lastListened]);
    NSUInteger numrules = [[source rules] count];
    
    if(numrules == 0) {
        [self removeFSWatcherFor:source];
        return;
    }
    
    if (nil == [source url]) {
        return;
    } 
    //this should not do any harm if we called it too often
    [PBWatcher watchPath: [[NSURL URLWithString:[source url]] path] notify:source];

}

-(void) removeFSWatcherFor:(Source *)source {
    [PBWatcher stopWatchingPath:[[NSURL URLWithString:[source url]] path]];
    
}


- (void)handleManagedObjectContextEvent:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    id inserted = [userInfo objectForKey:NSInsertedObjectsKey];        
    [self handleObjectsOf:[Source class] inSet:inserted withBlock:^(NSSet* sources){
        [self observe:sources];
    } ];
    
    id deleted = [userInfo objectForKey:NSDeletedObjectsKey];
    [self handleObjectsOf:[Source class] inSet:deleted withBlock:^(NSSet* sources){
        [self stopObserving:sources];
    } ];

    

}

- (void) handleObjectsOf:(Class)clazz inSet:(NSSet *)set withBlock:(void (^)(NSSet *))blk {
    if(set) {
        NSSet * changes = (NSSet *)set;
        NSSet * relevant =  [changes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", clazz]];
        blk(relevant);
    }

    
}

@end
