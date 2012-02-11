//
//  PBMetaDataDateExpression.m
//  Sorter
//
//  Created by Peter Brachwitz on 07/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDataDatePredicate.h"
#import "PBSingleDateStrategy.h"
#import "PBDefaultDateStrategy.h"
#import "PBVariableDateStrategy.h"


@interface PBMetaDataDatePredicate(PrivateAPI)     
- (id<PBMetaDataDateStrategy>) strategy;
+ (id<PBMetaDataDateStrategy>) strategyFor: (NSComparisonPredicate*) pred;
+ (NSArray *) supportedStrategies;
@end

@implementation PBMetaDataDatePredicate


+ (PBMetaDataDatePredicate *) predicateFromPredicate:(NSComparisonPredicate *)predicate {
    id <PBMetaDataDateStrategy> strat = [PBMetaDataDatePredicate strategyFor:predicate];
    if(strat) {
       PBMetaDataDatePredicate *obj = (PBMetaDataDatePredicate*) [super predicateWithLeftExpression:[predicate leftExpression] rightExpression:[predicate rightExpression] modifier:[predicate comparisonPredicateModifier] type:[predicate predicateOperatorType] options:[predicate options]];
        obj->strategy = strat;
        return  obj;
    }
    return nil;
    
}


+(NSArray *) supportedStrategies {
    return [NSArray arrayWithObjects:[PBSingleDateStrategy class], [PBVariableDateStrategy class],[PBDefaultDateStrategy class], nil];
}

+ (id <PBMetaDataDateStrategy>) strategyFor:(NSComparisonPredicate *)pred {
    id <PBMetaDataDateStrategy> result = nil;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSEnumerator *e = [[PBMetaDataDatePredicate supportedStrategies] objectEnumerator];
    id clazz;
    while (!result && (clazz = [e nextObject]) ) {
        id<PBMetaDataDateStrategy> cand = [[clazz alloc]init];
        if([cand canHandlePredicate:pred]) {
            result = cand;
        }            
    }
    [pool release]; 
    return result;

}

-(id <PBMetaDataDateStrategy>) strategy {
    if(self->strategy == nil) {
        self->strategy = [[PBMetaDataDatePredicate strategyFor:self] retain];
    }    
    return self->strategy;
}


- (NSString *)predicateFormat {
    id <PBMetaDataDateStrategy> strat = [self strategy];
    return [strat predicateFormatFor:self];
}




@end
