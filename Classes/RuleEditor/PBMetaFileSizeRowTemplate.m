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

#import "PBMetaFileSizeRowTemplate.h"


typedef struct  {
    double displayValue;
    long unitIndex;
} size_tuple;

size_tuple * calculateDisplaySize0(size_tuple* acc, NSInteger max_index) {
    double curr = acc->displayValue;
    if((curr > 0 && curr < 1000) || acc->unitIndex == max_index) {
        return acc;
    }
    acc->unitIndex++;
    acc->displayValue = curr/1000;
    return calculateDisplaySize0(acc, max_index);
    
}

size_tuple * calculateDisplaySize(NSNumber * bytes, NSInteger max_index, size_tuple * result) {
    result->unitIndex = -1;
    result->displayValue = [bytes doubleValue];
    return calculateDisplaySize0(result, max_index);
}


@implementation PBMetaFileSizeRowTemplate

static NSString * unitNames[] = {@"KB", @"MB", @"GB"};
//static NSInteger  unitFactors[] = {1024, 1048576, 1073741824};//Mac OS does not use IEC units in the GUI
static NSInteger  unitFactors[] = {1000, 1000000, 1000000000};
#define numberOfUnits() (sizeof(unitNames)/sizeof(unitNames[0]))


- (id) init {
    NSArray * operators = [NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:NSLessThanPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:NSLessThanOrEqualToPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:NSGreaterThanPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:NSGreaterThanOrEqualToPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:NSEqualToPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:NSNotEqualToPredicateOperatorType],
                           nil];

    self = [super initWithLeftExpressions:@[[NSExpression expressionForKeyPath:@"kMDItemFSSize"]] rightExpressionAttributeType:NSStringAttributeType modifier:NSDirectPredicateModifier operators:operators options:0];
    
    return self;
}

- (NSArray *) templateViews {
    NSMutableArray * views = [[super templateViews] mutableCopy];
    [views addObject:[self unitPopUpButton]];
    //NSTextField * numberInput = [views objectAtIndex:2];
    return [views autorelease];
}


- (NSPopUpButton *) unitPopUpButton {
    if (unitPopUpButton == nil) {
        unitPopUpButton = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        
        NSMenu * unitMenu = [unitPopUpButton menu];

        for (int i = 0; i < numberOfUnits(); i++) {
            [unitMenu addItemWithTitle:unitNames[i] action:NULL keyEquivalent:@""];
        }
    }
    return unitPopUpButton;
}


- (NSPredicate *) predicateWithSubpredicates:(NSArray *)subpredicates {
    NSPredicate * pred = [super predicateWithSubpredicates:subpredicates];
    if([pred isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comp  = (NSComparisonPredicate *) pred;
        
        NSExpression * right = [comp rightExpression];
        NSNumber * userValue = [right constantValue];
        NSInteger unitIndex = [[self unitPopUpButton] indexOfSelectedItem];
        NSNumber * constVal = [NSNumber numberWithInteger:([userValue doubleValue] * unitFactors[unitIndex])];
        NSExpression * var = [NSExpression expressionForConstantValue:constVal];
        
        pred = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:var modifier:[comp comparisonPredicateModifier] type:[comp predicateOperatorType] options:[comp options]];
        
    }
    
    return pred;
}

-(void) setPredicate:(NSPredicate *)predicate {
    NSComparisonPredicate * comp =  (NSComparisonPredicate *)predicate;

    //we assume a successful match has been established before -> calling convention
    NSNumber * bytes = [[comp rightExpression]constantValue];
    size_tuple * toDisplay = (size_tuple*) malloc(sizeof(size_tuple));
    calculateDisplaySize(bytes, numberOfUnits()-1, toDisplay);
    [[self unitPopUpButton] selectItemAtIndex:toDisplay->unitIndex];
    NSExpression * newRight = [NSExpression expressionForConstantValue:[NSNumber numberWithDouble:toDisplay->displayValue]];
    free(toDisplay);
    
    predicate = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression]
                                                   rightExpression:newRight
                                                          modifier:[comp comparisonPredicateModifier]
                                                              type:[comp predicateOperatorType]
                                                           options:[comp options]];
    [super setPredicate:predicate];
    
}


@end
