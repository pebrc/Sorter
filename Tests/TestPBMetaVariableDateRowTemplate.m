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

#import "TestPBMetaVariableDateRowTemplate.h"


static NSPredicate* createTestLastWeekPredicate() {
    NSString * minus1Week = @"$time.today(-1w)";
    NSString * todayPlusOne = @"$time.today(+1d)";
    return (NSComparisonPredicate*)[NSPredicate predicateWithFormat: @"kMDItemContentModificationDate BETWEEN %@", [NSArray arrayWithObjects:minus1Week, todayPlusOne, nil]]; 
    
}

static NSPredicate* createTestLastTwoMonthPredicate() {
    NSString * minus2Month = @"$time.today(-2M)";
    NSString * todayPlusOne = @"$time.today(+1d)";
    return (NSComparisonPredicate*)[NSPredicate predicateWithFormat: @"kMDItemContentModificationDate BETWEEN %@", [NSArray arrayWithObjects:minus2Month, todayPlusOne, nil]]; 
    
}





@implementation TestPBMetaVariableDateRowTemplate


-(void) setUp {
    NSArray * initialExpr = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"kMDItemContentModificationDate"], nil];
    template = [[PBMetaPresetRelativeDateRowTemplate alloc] initWithLeftExpressions:initialExpr];
}

// All code under test must be linked into the Unit Test bundle
- (void)testMatchLastWeek
{
    NSPredicate * testPredic = createTestLastWeekPredicate();
    double result = [template matchForPredicate:testPredic];
    STAssertEquals(result, DBL_MAX, @"match exprected");
}


-(void) testSetAndTransformLastWeek 
{
    NSPredicate * testPredic = createTestLastWeekPredicate();
    [template setPredicate:testPredic];
    NSPredicate * result = [template predicateWithSubpredicates:[NSArray array]];
    STAssertEqualObjects([result description], [testPredic description], @"should be the same");    
    
}

-(void)testNotBeingToEagerWhenMatching 
{
    double result = [template matchForPredicate:createTestLastTwoMonthPredicate()];
    STAssertEquals(result, 0.0, @"Should not match custom predicates");
    
}


@end
