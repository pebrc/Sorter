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

#import "PBMetaDataComparisonPredicate.h"
NSString * const PBLeftWildcard = @"*%@";
NSString * const PBRightWildcard = @"%@*";
NSString * const PBBothWildcard = @"*%@*";

#if __MAC_OS_X_VERSION_MIN_REQUIRED <= __MAC_10_6
typedef NSUInteger NSComparisonPredicateOptions;
#endif

typedef struct  {
    NSExpression * rhs;
    NSPredicateOperatorType type;
    NSComparisonPredicateOptions options;
} expr_tuple;

@interface PBMetaDataComparisonPredicate(private) 
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