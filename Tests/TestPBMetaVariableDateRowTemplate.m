//
//  TestPBMetaVariableDateRowTemplate.m
//  Sorter
//
//  Created by Peter Brachwitz on 19/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
