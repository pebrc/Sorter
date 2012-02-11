//
//  PBSingleDateStrategy.m
//  Sorter
//
//  Created by Peter Brachwitz on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBSingleDateStrategy.h"

@interface PBSingleDateStrategy(PrivateAPI) 
-(NSDate *) beginningOfDay:(NSDate*) day;
-(NSDate *) endOfDay: (NSDate *) day;


@end

@implementation PBSingleDateStrategy

-(BOOL) canHandlePredicate:(NSComparisonPredicate *)predicate {
        NSExpression *rhs = [predicate rightExpression];
        if ([rhs expressionType] == NSConstantValueExpressionType) {
            if ([[rhs constantValue]isKindOfClass:[NSDate class]] && [predicate predicateOperatorType] == NSEqualToPredicateOperatorType ) {
                return YES;
            }

        }    
    return NO;
}

- (NSString *) predicateFormatFor:(PBMetaDataComparisonPredicate *)predicate {
    return [NSString stringWithFormat:@"InRange(%@, %lf, %lf)", [self trimmedLhsOf:predicate], [[self beginningOfDay:[self representedDateIn:predicate]] timeIntervalSinceReferenceDate],[[self endOfDay:[self representedDateIn:predicate]] timeIntervalSinceReferenceDate]];
}

#pragma  mark PrivateAPI

- (NSDate *) beginningOfDay:(NSDate *)day {
    NSCalendar * cal =  [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:(NSDayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:day];
    return [[[cal dateFromComponents:comps] retain] autorelease];
}

- (NSDate*) endOfDay:(NSDate *)day {
    NSCalendar * cal =  [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:(NSDayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit) fromDate:day];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];
    return [[[cal dateFromComponents:comps] retain] autorelease];
}
@end
