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

#import "PBMetaPresetRelativeDateRowTemplate.h"

#define PBTodayPredicateOperatorType NSBetweenPredicateOperatorType
#define PBYesterdayPredicateOperatorType NSBeginsWithPredicateOperatorType
#define PBLastWeekPredicateOperatorType NSEndsWithPredicateOperatorType

@interface PBMetaPresetRelativeDateRowTemplate(PrivateAPI) 
- (void) initPresets;
- (BOOL) matchingVariables: (NSArray*) vars;
@end
@implementation PBMetaPresetRelativeDateRowTemplate
@synthesize persistedOperators, metaDataVariables;

- (id) init {
    if(self = [super init]) {
        [self initPresets];
    }
    return self;
}

- (id) initWithLeftExpressions:(NSArray *)leftExpressions {
    NSAttributeType  rightType = NSDateAttributeType;
    NSComparisonPredicateModifier modifier = NSDirectPredicateModifier;
    [self initPresets];
    NSArray * operators = [NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:PBTodayPredicateOperatorType],  
                           [NSNumber numberWithUnsignedInteger:PBYesterdayPredicateOperatorType],
                           [NSNumber numberWithUnsignedInteger:PBLastWeekPredicateOperatorType],
                            nil];
    return [super initWithLeftExpressions:leftExpressions rightExpressionAttributeType:rightType modifier:modifier operators:operators options:0];
}

- (void) initPresets {
    persistedOperators = [[NSArray arrayWithObjects:
                           [NSNumber numberWithUnsignedInteger:NSBetweenPredicateOperatorType], nil] retain];
    metaDataVariables = [[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSArray arrayWithObjects:@"$time.today", @"$time.today(+1)", nil], [NSNumber numberWithUnsignedInteger:PBTodayPredicateOperatorType],
                          [NSArray arrayWithObjects:@"$time.yesterday", @"$time.yesterday(+1)", nil],[NSNumber numberWithUnsignedInteger:PBYesterdayPredicateOperatorType],
                          [NSArray arrayWithObjects:@"$time.today(-1w)", @"$time.today(+1d)", nil], [NSNumber numberWithUnsignedInt:PBLastWeekPredicateOperatorType],
                          nil] retain];
}

- (NSArray*) templateViews {
    NSMutableArray * views = [[super templateViews] mutableCopy];
    NSPopUpButton * operatorView = [views objectAtIndex:1];
    [[operatorView itemAtIndex:0] setTitle:@"is today"];
    [[operatorView itemAtIndex:1] setTitle:@"is yesterday"];
    [[operatorView itemAtIndex:2] setTitle:@"is last Week"];

    [views removeObjectAtIndex:2];

    return [views autorelease];
    
}

- (double) matchForPredicate:(NSPredicate *)predicate {
    double nomatch = 0.0;
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
    if(![constantVal isKindOfClass:[NSDate class]]) {
        if([constantVal isKindOfClass:[NSArray class]]) {
            if ([self matchingVariables:(NSArray*)constantVal]) {
                return DBL_MAX;
            }
        }
        return nomatch;
    }
    
    return DBL_MAX;
    
}




- (NSPredicate *) predicateWithSubpredicates:(NSArray *)subpredicates {
    NSPredicate * pred = [super predicateWithSubpredicates:subpredicates];
    if([pred isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate *comp  = (NSComparisonPredicate *) pred;
        
        id constVal = [metaDataVariables objectForKey:[NSNumber numberWithUnsignedInt:[comp predicateOperatorType]]];
        NSExpression * var = [NSExpression expressionForConstantValue:constVal];
        
        pred = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:var modifier:[comp comparisonPredicateModifier] type:NSBetweenPredicateOperatorType options:[comp options]];
        
    }
    
    return pred;
}

- (void) setPredicate:(NSPredicate *)predicate {
    NSComparisonPredicate * comp = (NSComparisonPredicate*) predicate;
    NSExpression * rhs = [comp rightExpression];
    __block NSPredicateOperatorType  newOperator;
    NSArray * vals = [rhs constantValue];
    
    [metaDataVariables enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray * definedVars = obj;
        NSNumber * type = key;
        if([definedVars isEqualToArray:vals]) {
            newOperator = [type unsignedIntValue];
            *stop = YES;
        }
        
    }];
    
    
    predicate = [NSComparisonPredicate predicateWithLeftExpression:[comp leftExpression] rightExpression:rhs modifier:[comp comparisonPredicateModifier] type:newOperator options:[comp options]];
    [super setPredicate:predicate];
    
}

-(BOOL) matchingVariables:(NSArray *)vars {
    
    NSSet * matches = [metaDataVariables keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        NSArray * curr = (NSArray *) obj;
        if ([curr isEqualToArray:vars]) {
            *stop = YES;
            return YES;
        }
        return NO;

    }];
    return [matches count] > 0;
}

@end
