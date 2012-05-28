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
