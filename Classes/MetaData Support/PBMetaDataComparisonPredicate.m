//
//  PBMetaDataComparisonPredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDataComparisonPredicate.h"
NSString * const PBLeftWildcard = @"*%@";
NSString * const PBRightWildcard = @"%@*";
NSString * const PBBothWildcard = @"*%@*";

typedef struct  {
    NSExpression * rhs;
    NSPredicateOperatorType type;
    NSComparisonPredicateOptions options;
} expr_tuple;

@interface PBMetaDataComparisonPredicate(private) 
- (NSString *) operatorString;
- (NSString *) optionString;
+ (NSExpression*) addWildcardTo: (NSExpression *) orig left:(BOOL)l right:(BOOL)r;
+ (expr_tuple *) replaceNonCompatibleOperations: (expr_tuple *) tuple;
@end



@implementation PBMetaDataComparisonPredicate


+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options {
    expr_tuple tuple = {rhs, type, options};
    expr_tuple * res = [PBMetaDataComparisonPredicate replaceNonCompatibleOperations: &tuple];
    return [super predicateWithLeftExpression:lhs rightExpression:res->rhs modifier:modifier type:res->type options:res->options];
}

- (NSString*) predicateFormat {
    return [[NSString stringWithFormat:@"%@ %@ %@%@",[[self leftExpression] description], [self operatorString], [[self rightExpression] description], [self optionString] ]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
}

- (NSString *) operatorString {
    NSString * result;
    switch ([self predicateOperatorType]) {
        case NSLessThanPredicateOperatorType:
            result =  @"<";
            break;
        case NSLessThanOrEqualToPredicateOperatorType:
            result = @"<=";
            break;
        case NSGreaterThanPredicateOperatorType:
            result = @">";
            break;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            result = @">=";
            break;
        case NSEqualToPredicateOperatorType:
            result = @"==";
            break;
        case NSNotEqualToPredicateOperatorType:    
            result = @"!=";
            break;
        case NSMatchesPredicateOperatorType:
            result = @"matches";
            break;
        case NSBeginsWithPredicateOperatorType:
            result = @"beginswith";
            break;
        case NSLikePredicateOperatorType:
            result  = @"like";
            break;
        case NSEndsWithPredicateOperatorType:
            result = @"endswith";
            break;
        case NSInPredicateOperatorType:
            result = @"IN";
            break;
        case NSContainsPredicateOperatorType:
            result = @"CONTAINS";
            break;
        case NSBetweenPredicateOperatorType:
            result = @"BETWEEN";
            break;
        case NSCustomSelectorPredicateOperatorType:
        default:
            result = @"";
            break;
    }
    return result;    
}

- (NSString *) optionString {
    NSString * result = @"";
    NSComparisonPredicateOptions opts = [self options];
    if(opts & NSCaseInsensitivePredicateOption) {
        result = [result stringByAppendingString:@"c"];
    }
    if(opts & NSDiacriticInsensitivePredicateOption) {
        result = [result stringByAppendingString:@"d"];
    }
    return result;    
}

+ (NSExpression *) addWildcardTo:(NSExpression *)orig left:(BOOL)l right:(BOOL)r {
    if ([orig expressionType] != NSConstantValueExpressionType ) {
        return orig;
    }
    id constantValue = [orig constantValue];
    if([constantValue isKindOfClass:[NSString class]]){
        NSString * input = constantValue;
        NSString * str = l && r ? PBBothWildcard : (l ? PBLeftWildcard : PBRightWildcard);
        constantValue = [NSString stringWithFormat:str, input];
    }
    return [NSExpression expressionForConstantValue:constantValue];
}

+ ( expr_tuple *) replaceNonCompatibleOperations: ( expr_tuple *) tuple {

    switch (tuple->type) {
        case NSContainsPredicateOperatorType:
            tuple->type = NSEqualToPredicateOperatorType;
            tuple->rhs = [self addWildcardTo:tuple->rhs left:YES right:YES];
            break;
        case NSEndsWithPredicateOperatorType:
            tuple->type = NSEqualToPredicateOperatorType;
            tuple->rhs = [self addWildcardTo:tuple->rhs left:YES right:NO];
            break;
        case NSBeginsWithPredicateOperatorType:
            tuple->type = NSEqualToPredicateOperatorType;
            tuple->rhs = [self addWildcardTo:tuple->rhs left:NO right:YES];
            break; 
        case NSLikePredicateOperatorType:
            tuple->type = NSEqualToPredicateOperatorType;
            tuple->rhs = [self addWildcardTo:tuple->rhs left:YES right:YES];
            tuple->options = tuple->options | NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption;
            break;     
        default:            
            break;
    }
    return tuple;
    
    
}


@end