//
//  PBSourceObserver.m
//  Sorter
//
//  Created by Peter Brachwitz on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
