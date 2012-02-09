//
//  PBMetaDateRowTemplate.m
//  Sorter
//
//  Created by Peter Brachwitz on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDateRowTemplate.h"

@implementation PBMetaDateRowTemplate

- (id) initWithLeftExpressions:(NSArray *)leftExpressions {
    NSAttributeType  rightType = NSDateAttributeType;
    NSComparisonPredicateModifier modifier = NSDirectPredicateModifier;
    NSArray * operators = [NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:NSLessThanPredicateOperatorType],  
                           [NSNumber numberWithUnsignedInteger:NSGreaterThanPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:
                           NSEqualToPredicateOperatorType], nil];
    return [super initWithLeftExpressions:leftExpressions rightExpressionAttributeType:rightType modifier:modifier operators:operators options:0];
}

//- (NSPredicate *) predicateWithSubpredicates:(NSArray *)subpredicates {
//    NSPredicate * pred = [super predicateWithSubpredicates:subpredicates];
//    if([pred isKindOfClass:[NSComparisonPredicate class]]) {
//        NSComparisonPredicate *comp  = (NSComparisonPredicate *) pred;
//        NSExpression * rhs = [comp rightExpression];
//        NSDate * date = [rhs constantValue];
//        NSExpression * func = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects: date, [NSExpression expressionForConstantValue:@"NSDate"], nil]];
//        DEBUG_OUTPUT(@"function expression: %@", [func description]);
//        pred = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:func modifier:[comp comparisonPredicateModifier] type:[comp predicateOperatorType] options:[comp options]];
//        
//    }
//    
//    return pred;
//}

@end
