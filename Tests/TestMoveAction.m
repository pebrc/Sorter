//
//  TestMoveAction.m
//  Sorter
//
//  Created by Peter Brachwitz on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestMoveAction.h"


@implementation TestMoveAction


-(void) setUp {
    action = [[MoveAction alloc]init];
}

- (void)testYYYYexpandsToCurrentYear
{    
    
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSString * expected = [NSString stringWithFormat:@"/usr/local/bin/%u", [comps year]];
    
    id result =  [action performSelector:@selector(expandPlaceholders:) withObject:@"/usr/local/bin/$YYYY"];
    STAssertEqualObjects(result, expected, @"placed holder year should have been replaced");
    
}


-(void) testMMexpandsToCurrentMonth 
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSMonthCalendarUnit fromDate:[NSDate date]];
    NSString * expected = [NSString stringWithFormat:@"/usr/local/bin/%02u", [comps month]];
    id result =  [action performSelector:@selector(expandPlaceholders:) withObject:@"/usr/local/bin/$MM"];
    STAssertEqualObjects(result, expected, @"month place holder should have been replaced");
    
}


-(void) testDDexpandsToCurrentDay
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSDayCalendarUnit fromDate:[NSDate date]];
    NSString * expected = [NSString stringWithFormat:@"/usr/local/bin/%0u", [comps day]];
    id result =  [action performSelector:@selector(expandPlaceholders:) withObject:@"/usr/local/bin/$DD"];
    STAssertEqualObjects(result, expected, @"day place holder should have been replaced");
    
}

-(void) testCanCombineYearAndMonthVariable
{
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    NSString * expected = [NSString stringWithFormat:@"/usr/local/bin/%02u-%02u", [comps month], [comps year]];
    id result =  [action performSelector:@selector(expandPlaceholders:) withObject:@"/usr/local/bin/$MM-$YYYY"];
    STAssertEqualObjects(result, expected, @"both year and month place holders should have been replaced");
     
    
}


@end
