//
//  PBDefaultDateStrategy.m
//  Sorter
//
//  Created by Peter Brachwitz on 11/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBDefaultDateStrategy.h"

@implementation PBDefaultDateStrategy

-(BOOL) canHandlePredicate:(NSComparisonPredicate *)predicate {
        NSExpression *rhs = [predicate rightExpression];
        if ([rhs expressionType] == NSConstantValueExpressionType) {
            if ([[rhs constantValue]isKindOfClass:[NSDate class]]) {
                return YES;
            }
            
        }
        return NO;
}


-(NSString*) predicateFormatFor:(PBMetaDataComparisonPredicate *)predicate {
    return [NSString stringWithFormat:@"%@ %@ %lf",[self trimmedLhsOf:predicate], [predicate operatorString], [[self representedDateIn:predicate] timeIntervalSinceReferenceDate] ];
}


@end
