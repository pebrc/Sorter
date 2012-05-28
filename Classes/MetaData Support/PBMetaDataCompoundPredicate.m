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

#import "PBMetaDataCompoundPredicate.h"

NSString * const PBAndPredicateType = @"&&";
NSString * const PBOrPredicateType = @"||";

@interface PBMetaDataCompoundPredicate(PrivateAPI) 
-(NSString*) compoundStringWithWhitespace;
-(NSString*) compoundString;
@end

@implementation PBMetaDataCompoundPredicate

-(NSString*) predicateFormat {
    NSArray * subs = [self subpredicates];
    NSMutableArray * formatted = [NSMutableArray arrayWithCapacity:[subs count]];
    for (id pred in subs) {
        [formatted addObject:[pred predicateFormat]];
    }
    return [formatted componentsJoinedByString:[self compoundStringWithWhitespace]];
}


-(NSString*) compoundStringWithWhitespace {
    return [NSString stringWithFormat:@" %@ ", [self compoundString]];
    
}

-(NSString *)compoundString{
    NSCompoundPredicateType t = [self compoundPredicateType];
    switch (t) {
        case NSAndPredicateType:
            return PBAndPredicateType;
            break;
        case NSOrPredicateType:
            return PBOrPredicateType;
            break;
        case NSNotPredicateType:
            [NSException raise:@"Operation not supported" format:@"Not predicate ist not supported in spotlight"];
            break;
    }
    return @"";
}

@end
