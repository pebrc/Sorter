//
//  PBMetaDataCompoundPredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 08/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDataCompoundPredicate.h"

NSString * const PBAndPredicateType = @"&&";
NSString * const PBOrPredicateType = @"||";

@interface PBMetaDataCompoundPredicate(PrivateAPI) 
-(NSString*) compoundStringWithWhitespace;
-(NSString*) compoundString;
@end

@implementation PBMetaDataCompoundPredicate

-(NSString*) predicateFormat {
    NSArray * subs = [self subpredicates];
    NSMutableArray * formatted = [NSMutableArray arrayWithCapacity:[subs count]];
    for (id pred in subs) {
        [formatted addObject:[pred predicateFormat]];
    }
    return [formatted componentsJoinedByString:[self compoundStringWithWhitespace]];
}


-(NSString*) compoundStringWithWhitespace {
    return [NSString stringWithFormat:@" %@ ", [self compoundString]];
    
}

-(NSString *)compoundString{
    NSCompoundPredicateType t = [self compoundPredicateType];
    switch (t) {
        case NSAndPredicateType:
            return PBAndPredicateType;
            break;
        case NSOrPredicateType:
            return PBOrPredicateType;
            break;
        case NSNotPredicateType:
            [NSException raise:@"Operation not supported" format:@"Not predicate ist not supported in spotlight"];
            break;
    }
    return @"";
}

@end
