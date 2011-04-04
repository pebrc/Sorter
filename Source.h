//
//  Source.h
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PBEvent.h"

@class Rule;

@interface Source :  NSManagedObject  < PBEventListener >
{
    PBWatcher * watcher;
}

@property (nonatomic, assign) NSNumber * eventid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet* rules;

@end


@interface Source (CoreDataGeneratedAccessors)
- (void)addRulesObject:(Rule *)value;
- (void)removeRulesObject:(Rule *)value;
- (void)addRules:(NSSet *)value;
- (void)removeRules:(NSSet *)value;

@end

