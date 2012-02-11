//
//  PBVariableDateStrategy.m
//  Sorter
//
//  Created by Peter Brachwitz on 11/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBVariableDateStrategy.h"


@implementation PBVariableDateStrategy

-(BOOL) canHandlePredicate:(NSComparisonPredicate *)predicate {
    NSExpression *rhs = [predicate rightExpression];
    if ([rhs expressionType] == NSConstantValueExpressionType) {
        if ([[rhs description] rangeOfString:@"$time"].location != NSNotFound) {
            return YES;
        }        
    }
    return NO;

}

-(NSString *) predicateFormatFor:(PBMetaDataComparisonPredicate *)predicate {
    NSArray * vals = [[predicate rightExpression] constantValue];
    return [NSString stringWithFormat:@"InRange(%@, %@, %@)", [self trimmedLhsOf:predicate], [vals objectAtIndex:0], [vals objectAtIndex:1]];

    
}

@end
