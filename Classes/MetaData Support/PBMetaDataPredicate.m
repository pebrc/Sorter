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

#import "PBMetaDataPredicate.h"
#import "PBMetaDataComparisonPredicate.h"
#import "PBMetaDataDatePredicate.h"
#import "PBMetaDataCompoundPredicate.h"


@interface PBMetaDataPredicate(private) 
- (id) initWithPredicate: (NSPredicate*) original;
- (NSPredicate*) spotifiedPredicate: (NSPredicate*) source;
@end

@implementation PBMetaDataPredicate

+(PBMetaDataPredicate *) predicateFromPredicate:(NSPredicate *)source {
    PBMetaDataPredicate * pred = [[[PBMetaDataPredicate alloc] initWithPredicate:source] autorelease];
    return pred;
}

- (id) initWithPredicate:(NSPredicate *)source {
    self = [super init];
    if (self) {
        original = [self spotifiedPredicate:source];
    }
    return self;
}

- (NSString*) predicateFormat {
    return [original predicateFormat];
}

-(NSPredicate *) spotifiedPredicate: (NSPredicate*) source {
	if (nil == source) {
		return source;
	}
	if ([source isKindOfClass:[NSCompoundPredicate class]]) {
		NSCompoundPredicateType type = [(NSCompoundPredicate*) source compoundPredicateType];
		NSMutableArray *resultingSubPredicates = [NSMutableArray array];
		for (NSPredicate * origSubPredicate in [(NSCompoundPredicate*) source subpredicates]) {
			NSPredicate *spotifiedSubPredicate = [self spotifiedPredicate:origSubPredicate];
			if (spotifiedSubPredicate) {
				[resultingSubPredicates addObject:spotifiedSubPredicate];
			}
		}
		NSUInteger numPredicates = [resultingSubPredicates count];
		if ( numPredicates == 0) {
			return nil;
		} else if (numPredicates == 1) {
			return [resultingSubPredicates objectAtIndex:0];
		} else {
			return [[[PBMetaDataCompoundPredicate alloc] initWithType:type subpredicates:resultingSubPredicates] autorelease];
		}
        
	} else if ([source isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate * src = (NSComparisonPredicate*) source;
        NSPredicate * res = [PBMetaDataDatePredicate predicateFromPredicate:src];
        if (!res) {
            return [PBMetaDataComparisonPredicate predicateWithLeftExpression:[src leftExpression] 
                                                              rightExpression:[src rightExpression] 
                                                                     modifier:[src comparisonPredicateModifier]
                                                                         type:[src predicateOperatorType]
                                                                      options:[src options]];
        }
        return res;
	}
	return source;
}



@end
