//
//  PBMetaDataDateExpression.m
//  Sorter
//
//  Created by Peter Brachwitz on 07/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDataDatePredicate.h"
@interface PBMetaDataDatePredicate(PrivateAPI) 
-(NSDate *) beginningOfDay:(NSDate*) day;
-(NSDate *) endOfDay: (NSDate *) day;
-(NSDate *) representedDate;
-(NSString *) trimmedLhs;
@end

@implementation PBMetaDataDatePredicate





- (NSString *)predicateFormat {
    return [NSString stringWithFormat:@"InRange(%@, %lf, %lf)", [self trimmedLhs], [[self beginningOfDay:[self representedDate]] timeIntervalSinceReferenceDate],[[self endOfDay:[self representedDate]] timeIntervalSinceReferenceDate]];
}

#pragma PrivateAPI

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

-(NSDate *)representedDate {
    return (NSDate*)[[self rightExpression] constantValue];
}

-(NSString*) trimmedLhs {
    return [[[self leftExpression] description] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
}

@end
