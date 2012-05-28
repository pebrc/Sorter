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
//THE SOFTWARE.

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
