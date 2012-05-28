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
//THE SOFTWARE.Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
        id<PBMetaDataDateStrategy> cand = [[[clazz alloc]init] autorelease];
        if([cand canHandlePredicate:pred]) {
            result = [cand retain];
        }            
    }
    [pool drain]; 
    return [result autorelease];

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
