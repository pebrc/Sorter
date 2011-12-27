//
//  TestPBMetaDataComparisonPredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TestPBMetaDataComparisonPredicate.h"
#import "PBMetaDataComparisonPredicate.h"
@interface PBMetaDataComparisonPredicate(TestExposure) 
    + (NSExpression*) addWildcardTo: (NSExpression *) orig left:(BOOL)l right:(BOOL)r;
@end
@implementation TestPBMetaDataComparisonPredicate

// All code under test must be linked into the Unit Test bundle
- (void)testPredicateFormatEquals
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent == %@", @"Bawag"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = [pred predicateFormat];
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);
}

- (void) testPredicateFormatEqualsIgnoreCase 
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent ==[c] %@", @"Bawag"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"Bawag\"c"; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);
    
}

- (void) testPredicateFormatEqualsIgnoreDiacritics 
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent ==[d] %@", @"Bawag"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"Bawag\"d"; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);
    
}

- (void) testPredicateFormatEqualsIgnoresBoth 
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent ==[dc] %@", @"Bawag"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"Bawag\"cd"; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);
    
}

- (void) testPredicateFormatEndsWith 
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent ENDSWITH %@", @"value"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"*value\""; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);
    
}

- (void) testPredicateFormatBeginnsWith
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent BEGINSWITH %@", @"value"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"value*\""; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);

    
}

- (void) testPredicateFormatLike
{
    NSComparisonPredicate * pred = (NSComparisonPredicate *) [NSPredicate predicateWithFormat:@"kMDItemTextContent LIKE %@", @"value"];
    PBMetaDataComparisonPredicate * subj = (PBMetaDataComparisonPredicate *)[PBMetaDataComparisonPredicate predicateWithLeftExpression:[pred leftExpression] rightExpression:[pred rightExpression] modifier:[pred comparisonPredicateModifier] type:[pred predicateOperatorType] options:[pred options]];
    NSString * exp = @"kMDItemTextContent == \"*value*\"cd"; 
    NSString * act = [subj predicateFormat];
    STAssertTrue([act isEqualToString: exp], @"Expected: %@ but found %@", exp, act);    
}

- (void) testLeftWildcard 
{
    NSExpression * expected  = [NSExpression expressionForConstantValue:@"*value"];
    NSExpression * orig = [NSExpression expressionForConstantValue:@"value"];
    NSExpression * result = [PBMetaDataComparisonPredicate addWildcardTo: (NSExpression *) orig left:YES right:NO];
    STAssertTrue([[result description] isEqualToString: [expected description]], @"A wildcard to the left should have been added: %@", [result description]);
}

- (void) testRightWildcard {
    NSExpression * expected  = [NSExpression expressionForConstantValue:@"value*"];
    NSExpression * orig = [NSExpression expressionForConstantValue:@"value"];
    NSExpression * result = [PBMetaDataComparisonPredicate addWildcardTo: (NSExpression *) orig left:NO right:YES];
    STAssertTrue([[result description] isEqualToString: [expected description]], @"A wildcard to the right should have been added: %@", [result description]);
    
}

- (void) testBothWildcard {
    NSExpression * expected  = [NSExpression expressionForConstantValue:@"*value*"];
    NSExpression * orig = [NSExpression expressionForConstantValue:@"value"];
    NSExpression * result = [PBMetaDataComparisonPredicate addWildcardTo: (NSExpression *) orig left:YES right:YES];
    STAssertTrue([[result description] isEqualTo: [expected description]], @"A wildcard should have been added to both sides of the value: %@", [result description]);
}
@end
