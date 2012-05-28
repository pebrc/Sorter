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

#import "TestPBMetaRelativeDateRow.h"

static NSPredicate* createTestLastWeekPredicate() {
    NSString * minus1Week = @"$time.today(-1w)";
    NSString * todayPlusOne = @"$time.today(+1d)";
    return (NSComparisonPredicate*)[NSPredicate predicateWithFormat: @"kMDItemContentModificationDate BETWEEN %@", [NSArray arrayWithObjects:minus1Week, todayPlusOne, nil]]; 
    
}

static NSPredicate* createTestNextWeekPredicate() {
    NSString * plus1Week = @"$time.today(+1w)";
    NSString * today = @"$time.today";
    return (NSComparisonPredicate*)[NSPredicate predicateWithFormat: @"kMDItemContentModificationDate BETWEEN %@", [NSArray arrayWithObjects:today, plus1Week, nil]]; 
    
}

@implementation TestPBMetaRelativeDateRow

-(void) setUp {
    NSArray * initialExpr = [NSArray arrayWithObjects:[NSExpression expressionForKeyPath:@"kMDItemContentModificationDate"], nil];
    template = [[PBMetaRelativeDateRowTemplate alloc] initWithLeftExpressions:initialExpr];
}


-(void) testDoesNotMatchPresetDateWithMaxPrio {
    NSPredicate * relativePred = createTestLastWeekPredicate();
    double result =[template matchForPredicate:relativePred];
    STAssertEquals(result, DBL_MAX -1, @"Should match but not with max priority so that the other template can pick it up");
}

- (void) testDoesNotMatchDateInTheNextWeekYet {
    NSPredicate * relativePred = createTestNextWeekPredicate();
    double result =[template matchForPredicate:relativePred];
    STAssertEquals(result, 0.0, @"Should not match");
}

-(void) testWhenSelectingInTheLastTwoMonthsYieldsCorrespondingResult{
    NSPredicate * relativePred = createTestLastWeekPredicate();
    [template setPredicate:relativePred];
    NSArray * views = [template templateViews];
    NSPopUpButton * typeSelect = [views objectAtIndex:1];
    [typeSelect selectItemAtIndex:0];
    NSTextField * varInput = [views objectAtIndex:2];
    [varInput setDoubleValue:2.0];
    NSPopUpButton * unit = [views objectAtIndex:3];
    [unit selectItemAtIndex:2];
    NSPredicate * result = [template predicateWithSubpredicates:[NSArray array]];
    NSString * expected = [NSString stringWithFormat:@"kMDItemContentModificationDate BETWEEN {\"$time.today(-2M)\", \"$time.today(+1d)\"}"];
    STAssertEqualObjects([result description], expected, @"should be a predicate with -2M as the variable values");
    
}

-(void) testOutputShouldBeWhatWasPutIn {
    NSPredicate* inTheLastTwoWeeks = createTestLastWeekPredicate();
    [template setPredicate:inTheLastTwoWeeks];
    NSPredicate * result = [template predicateWithSubpredicates:[NSArray array]];
    STAssertEqualObjects([inTheLastTwoWeeks description], [result description], @"should correspond to the predicate that was used as input");
    
}

-(void) testThatBetweenIsNotAUserSelectableOption {
    NSArray * views = [template templateViews];
    NSPopUpButton * typeSelect = [views objectAtIndex:1];
    NSInteger index = [typeSelect indexOfItemWithTitle:@"matches"];
    STAssertEquals(index, -1l, @"should not be available");


}

@end
