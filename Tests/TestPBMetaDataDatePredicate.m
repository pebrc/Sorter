//
//  TestPBMetaDataDatePredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 07/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestPBMetaDataDatePredicate.h"
#import "PBMetaDataPredicate.h"
#import <objc/runtime.h>

static const double test_date = 346717732.825463; //26.12.2011 22:31 ...
static const double test_day_from = 346636800; //26.12.2011 0:00
static const double test_day_until = 346723199;//26.12.2011 23:59


NSString * const TestOnDate = @"%@ == CAST(%lf, \"NSDate\")";
NSString * const TestBeforeDate = @"%@ < CAST(%lf, \"NSDate\")";
NSString * const TestAfterDate = @"%@ > CAST(%lf, \"NSDate\")";

@implementation TestPBMetaDataDatePredicate

-(void) setUp {
    NSTimeZone * tz = [NSTimeZone defaultTimeZone];
    NSDate * testDate = [NSDate dateWithTimeIntervalSinceReferenceDate:test_date];
    NSInteger offset =  [tz secondsFromGMTForDate:testDate];
    local_day_from = test_day_from - offset;
    local_day_until = test_day_until - offset;
}

// All code under test must be linked into the Unit Test bundle
- (void)testExistingImplementationInRange
{
    NSString * input = @"InRange(kMDItemContentCreationDate,346633200, 346719600)";
    STAssertThrows([NSPredicate predicateWithFormat:input], @"InRange should not be supported by the parser at the moment");
}


- (void) testExistingImplementationTime 
{
    NSString * input = @"kMDItemContentCreationDate == $time.now";
    NSPredicate * pred = [NSPredicate predicateWithFormat:input]; 
    STAssertTrue([[pred predicateFormat] isEqualToString: input], @"Result was %@ , expected %@", [pred predicateFormat], input);
    
}

- (void) testExistingFunctionExpression 
{
    NSExpression *exp = [NSExpression expressionForFunction:@"now" arguments:[NSArray array]];
    STAssertTrue([exp expressionType] == NSFunctionExpressionType, @"not a function expresion");
}

- (void) testCreatingFunctionExpressions
{
    NSExpression * exp = [NSExpression expressionForFunction:@"castObject:toType:" arguments:[NSArray arrayWithObjects:[NSDate date], [NSExpression expressionForConstantValue:@"NSDate"], nil]];
    STAssertTrue([exp expressionType] == NSFunctionExpressionType, @"not a function expresion");
    STAssertTrue([[exp function] isEqualToString:@"castObject:toType:"],@"not the function we created: %@", [exp function] );

}

- (void) testCreatingImplicitCast 
{
    NSExpression * exp = [NSExpression expressionForConstantValue:[NSDate date]];
    NSString * description = [exp description];
    STAssertFalse([description rangeOfString:@"CAST"].location == NSNotFound, @"implicit cast exprected");

}

- (void) testCreatingConstantValueExprReturn 
{
    NSExpression * exp = [NSExpression expressionForConstantValue:[NSDate date]];
    id  description = [exp constantValue];
    STAssertTrue([description isKindOfClass:[NSDate class]], @"implicit nsdate exprected");
    
}




//exactely InRange(kMDItemContentCreationDate,346633200,     346719600)))

- (void) testExactDatePredicate {
    
    NSComparisonPredicate * orig = (NSComparisonPredicate*)[NSPredicate predicateWithFormat:TestOnDate, @"kMDItemContentCreationDate", test_date]; 
    PBMetaDataPredicate * pred = [PBMetaDataPredicate predicateFromPredicate:orig];
    NSString * expected = [NSString stringWithFormat:@"InRange(kMDItemContentCreationDate, %lf, %lf)", local_day_from, local_day_until ];
    STAssertEqualObjects([pred predicateFormat],expected, @"Not a spotlight compatible result");
        
}


- (void) testKeyPathAttributesArePassedThroughToWrapper {
    NSComparisonPredicate * orig = (NSComparisonPredicate*)[NSPredicate predicateWithFormat:TestOnDate, @"kMDItemContentModificationDate", test_date]; 
    PBMetaDataPredicate * pred = [PBMetaDataPredicate predicateFromPredicate:orig];

    NSString * expected = [NSString stringWithFormat:@"InRange(kMDItemContentModificationDate, %lf, %lf)", local_day_from, local_day_until ];
    STAssertEqualObjects([pred predicateFormat],expected, @"Not the correct attribute in the result");

    
}

//before (kMDItemContentCreationDate &lt; 347583600))
- (void) testBeforeFixedDate {
    NSComparisonPredicate * orig = (NSComparisonPredicate*)[NSPredicate predicateWithFormat: TestBeforeDate,@"kMDItemContentModificationDate", test_date]; 
    PBMetaDataPredicate * pred = [PBMetaDataPredicate predicateFromPredicate:orig];
    NSString * expected = [NSString stringWithFormat:@"kMDItemContentModificationDate < %lf", test_date]; 
    STAssertEqualObjects([pred predicateFormat],expected, @"This should be a the attribute, a less than operater and a double value");
    
}


//after

- (void) testAfterFixedDate {
    NSComparisonPredicate * orig = (NSComparisonPredicate*)[NSPredicate predicateWithFormat: TestAfterDate,@"kMDItemContentModificationDate", test_date]; 
    PBMetaDataPredicate * pred = [PBMetaDataPredicate predicateFromPredicate:orig];
    NSString * expected = [NSString stringWithFormat:@"kMDItemContentModificationDate > %lf", test_date]; 
    STAssertEqualObjects([pred predicateFormat],expected, @"This should be a the attribute, a greater than operater and a double value");
    
}

-(void) testWithLastXDays {
    NSString * minus10Days = @"$time.today(-10d)";
    NSString * todayPlusOne = @"time.today(+1d)";
    NSComparisonPredicate * orig = (NSComparisonPredicate*)[NSPredicate predicateWithFormat: @"%@ BETWEEN %@",@"kMDItemContentModificationDate", [NSArray arrayWithObjects:minus10Days, todayPlusOne, nil]]; 
    PBMetaDataPredicate * pred = [PBMetaDataPredicate predicateFromPredicate:orig];
    NSString * expected = [NSString stringWithFormat:@"InRange(kMDItemContentModificationDate, %@, %@)", minus10Days, todayPlusOne]; 
    STAssertEqualObjects([pred predicateFormat],expected, @"This should be an inrange function , the attribute and two time variables");


    
}



//Test to write:
//nil strategy

//within last x days

//today  InRange(kMDItemContentCreationDate,$time.today,$time.today(+1)))
//yesterday
//this week InRange(kMDItemContentCreationDate, $time.today(-1w),$time.today(+1d))
//this month
//this year


//- (void) testExistingDateExpression 
//{
//    NSString * input = @"%@ == CAST(346717732.825463, \"NSDate\")";
//    NSPredicate * pred = [NSPredicate predicateWithFormat:input, @"kMDItemContentCreationDate"]; 
//    STAssertTrue([pred isKindOfClass: [NSComparisonPredicate class]], @"not a comparison predicate");
//    NSComparisonPredicate *comp = (NSComparisonPredicate *)pred;
//    NSExpression * exp = [comp rightExpression];
//    STAssertTrue([exp expressionType] == NSConstantValueExpressionType, @"not a constant value expresion");
//    unsigned int count;
//    Method *methods = class_copyMethodList([exp class], &count);
//    for(unsigned i = 0; i < count; i++) {
//        SEL selector = method_getName(methods[i]);
//        const char* methodName = sel_getName(selector);
//        NSLog(@"Method: %@",[NSString stringWithCString:methodName encoding:NSUTF8StringEncoding]);
//}
////    Sorter[57829:307] dealloc
////    2012-01-07 22:21:34.669 Sorter[57829:307] isEqual:
////    2012-01-07 22:21:34.670 Sorter[57829:307] expressionValueWithObject:context:
////    2012-01-07 22:21:34.671 Sorter[57829:307] hash
////    2012-01-07 22:21:34.675 Sorter[57829:307] copyWithZone:
////    2012-01-07 22:21:34.678 Sorter[57829:307] encodeWithCoder:
////    2012-01-07 22:21:34.680 Sorter[57829:307] initWithObject:
////    2012-01-07 22:21:34.684 Sorter[57829:307] initWithCoder:
////    2012-01-07 22:21:34.686 Sorter[57829:307] constantValue
////    2012-01-07 22:21:34.687 Sorter[57829:307] predicateFormat
////    2012-01-07 22:21:34.688 Sorter[57829:307] expressionValueWithObject:
//
//    
//    
//}

@end
