//
//  PBAbstractDateStrategy.m
//  Sorter
//
//  Created by Peter Brachwitz on 11/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBAbstractDateStrategy.h"

@implementation PBAbstractDateStrategy

-(BOOL) canHandlePredicate:(NSComparisonPredicate *)predicate {
    [NSException raise:@"Abstract method" format:@"implement in subclass"];
    return NO;
}

-(NSString*) predicateFormatFor:(PBMetaDataComparisonPredicate *)predicate {
    [NSException raise:@"Abstract method" format:@"implement in subclass"];
    return @"";
}

-(NSString*) trimmedLhsOf:(PBMetaDataComparisonPredicate *)predicate {
    return [[[predicate leftExpression] description] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
}

-(NSDate *)representedDateIn:(PBMetaDataComparisonPredicate *)predicate {
    return (NSDate*)[[predicate rightExpression] constantValue];
}

@end
