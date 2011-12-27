//
//  PBMetaDataPredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PBMetaDataPredicate.h"
#import "PBMetaDataComparisonPredicate.h"


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
			return [[[NSCompoundPredicate alloc] initWithType:type subpredicates:resultingSubPredicates] autorelease];
		}
        
	} else if ([source isKindOfClass:[NSComparisonPredicate class]]) {
        NSComparisonPredicate * src = (NSComparisonPredicate*) source;
		return [PBMetaDataComparisonPredicate predicateWithLeftExpression:[src leftExpression] 
												  rightExpression:[src rightExpression] 
														 modifier:[src comparisonPredicateModifier]
															 type:[src predicateOperatorType]
														  options:[src options]];
	}
	return source;
}



@end
