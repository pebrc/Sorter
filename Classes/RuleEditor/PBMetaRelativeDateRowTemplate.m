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

#import "PBMetaRelativeDateRowTemplate.h"

#define PBInTheLastPredicateOperatorType NSMatchesPredicateOperatorType

@interface PBMetaRelativeDateRowTemplate(PrivateAPI) 
- (void) initPresets;
- (NSString*) selectedUnit;
- (NSUInteger) indexOfUnit:(NSString*) unit;
- (NSString*) correspondingSign: (NSPredicateOperatorType) type;
- (BOOL) scanVariables: (NSArray*) vars forType: (NSPredicateOperatorType) type;
@end



@implementation PBMetaRelativeDateRowTemplate

@synthesize persistedOperators, significantPart;
static  NSString * otherPart = @"$time.today";
static  NSString * commonPrefix = @"$time.today(";
static  NSString * commonSuffix = @")";
static  NSString * unitNames[] = {@"days", @"weeks", @"months", @"years"};
static  NSString * unitIntervals[] = {@"d", @"w", @"M", @"Y"};
#define numberOfUnits() (sizeof(unitNames)/sizeof(unitNames[0]))


- (id) init {
    if(self = [super init]) {
        [self initPresets];
    }
    return self;
}

- (id) initWithLeftExpressions:(NSArray *)leftExpressions {
    NSAttributeType  rightType = NSDoubleAttributeType;
    NSComparisonPredicateModifier modifier = NSDirectPredicateModifier;
    [self initPresets];
    NSArray * operators = [NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:PBInTheLastPredicateOperatorType],  
                           //[NSNumber numberWithUnsignedInt:NSBetweenPredicateOperatorType],
                           nil];
    return [super initWithLeftExpressions:leftExpressions rightExpressionAttributeType:rightType modifier:modifier operators:operators options:0];
}

- (void) initPresets {
    persistedOperators = [[NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:NSBetweenPredicateOperatorType], nil] retain];
    significantPart = [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:0], [NSNumber numberWithUnsignedInteger:PBInTheLastPredicateOperatorType], nil]retain];
}

- (NSPopUpButton *) unitPopUpButton {
    if (unitPopUpButton == nil) {
        unitPopUpButton = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
        
        NSMenu * unitMenu = [unitPopUpButton menu];
        for (int i = 0; i < numberOfUnits(); ++i) {
            [unitMenu addItemWithTitle:unitNames[i] action:NULL keyEquivalent:@""];
        }
    }
    return unitPopUpButton;
}

- (void) dealloc {
    [unitPopUpButton release];
    [persistedOperators release];
    [significantPart release];
    [super dealloc];
}


- (NSArray *) templateViews {
    NSMutableArray * views = [[super templateViews] mutableCopy];
    
    [views addObject:[self unitPopUpButton]];
    
    NSPopUpButton * operatorView = [views objectAtIndex:1];
    [[operatorView itemAtIndex:0] setTitle:@"is in the last"];
    //[operatorView removeItemWithTitle:@"matches"];
    
    return [views autorelease];
}

-(double) matchForPredicate:(NSPredicate *)predicate {
    double nomatch = 0.0;
    double match = DBL_MAX - 1;
    if(![predicate isKindOfClass:[NSComparisonPredicate class]]) {
        return nomatch;
    }
    
    NSComparisonPredicate * comp = (NSComparisonPredicate*)predicate;
    if(![[self leftExpressions]containsObject:[comp leftExpression]]) {
        return nomatch;
    }
    
    if(![[self persistedOperators] containsObject:[NSNumber numberWithUnsignedInt:[comp predicateOperatorType]]]) {
        return nomatch;
    }
    
    if([[comp rightExpression] expressionType] != NSConstantValueExpressionType) {
        return nomatch;
    }
    
    id constantVal = [[comp rightExpression] constantValue];
    if([constantVal isKindOfClass:[NSArray class]]) {
        if([self scanVariables:constantVal forType:[comp predicateOperatorType]])
                return match;
    }
    return nomatch;

}

-(BOOL) scanVariables:(NSArray *)vars forType:(NSPredicateOperatorType)type {
    if(lastScanned && [lastScanned isEqualToArray:vars]) {
        return YES;
    }
    NSNumber * index = (NSNumber *)[significantPart objectForKey:[NSNumber numberWithUnsignedInteger:type]];
    //this just works by accident! nil == 0x0
    NSString * significantString = [vars objectAtIndex: [index unsignedIntValue]];
    int numUnits;
    NSString * unit;
    NSScanner * scanner = [NSScanner scannerWithString:significantString];

        if (
            [scanner scanString:commonPrefix intoString:NULL] &&
            [scanner scanInt:&numUnits] &&
            [scanner scanUpToString:commonSuffix intoString:&unit]
            ) 
        {
            lastUnit = unit;
            lastNumUnits = numUnits;
            lastScanned = vars;
            return YES;
        }
        
    
    return NO;
}

-(NSPredicate*) predicateWithSubpredicates:(NSArray *)subpredicates {
    NSPredicate * pred = [super predicateWithSubpredicates:subpredicates];
    if([pred isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comp  = (NSComparisonPredicate *) pred;
        int numUnits = [(NSNumber*)[[comp rightExpression] constantValue]intValue];
        NSString * unit = [self selectedUnit];
        NSPredicateOperatorType type = [comp predicateOperatorType];
        NSUInteger variableIndex = [(NSNumber *)[significantPart objectForKey:[NSNumber numberWithUnsignedInteger:type]]unsignedIntValue];
        NSString * sign = [self correspondingSign:type];
        NSString * variablePart = [NSString stringWithFormat:@"%@%@%d%@%@", commonPrefix,sign, numUnits, unit, commonSuffix];
        
        NSMutableArray * vals;
        if(variableIndex == 0 ) {
            vals = [NSArray arrayWithObjects:variablePart, [NSString stringWithFormat:@"%@(+1d)",otherPart], nil];
        } else {
            vals = [NSArray arrayWithObjects:otherPart, variablePart, nil];
        }
        NSExpression * var = [NSExpression expressionForConstantValue:vals];
        pred = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:var modifier:[comp comparisonPredicateModifier] type:NSBetweenPredicateOperatorType options:[comp options]];

        
    }
    return pred;

}

-(NSString *) selectedUnit {
   NSInteger index =  [[self unitPopUpButton] indexOfSelectedItem];
    if(index > numberOfUnits())  {
        [NSException raise:@"invalid index: cannot select unit" format:nil];
    }
    return unitIntervals[index];
}

-(NSString *) correspondingSign:(NSPredicateOperatorType)type {
    switch (type) {
        case PBInTheLastPredicateOperatorType:
            return @"-";            
        default:
            return @"+";
    }
}

-(void) setPredicate:(NSPredicate *)predicate {
    NSComparisonPredicate * comp =  (NSComparisonPredicate *)predicate;
    NSPredicateOperatorType type = [comp predicateOperatorType];
    //we assume a successful match has been established before -> calling convention
    NSArray * vals = [[comp rightExpression]constantValue];
    if([self scanVariables:vals forType:type]) {
        [[self unitPopUpButton] selectItemAtIndex:[self indexOfUnit:lastUnit]];
        NSExpression * rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithInt:abs(lastNumUnits)]];
        
        predicate = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:rhs modifier:[comp comparisonPredicateModifier] type:PBInTheLastPredicateOperatorType options:[comp options]];
        [super setPredicate:predicate];
    }
}

-(NSUInteger) indexOfUnit:(NSString *)unit {
    int l = numberOfUnits();
    for (int i = 0; i < l; i++) {
        if([unit isEqualToString:unitIntervals[i]]) {
            return i;
        }
    }
    return 0;
}


@end
