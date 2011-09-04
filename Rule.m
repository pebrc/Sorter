//Copyright (c) 2011 Peter Brachwitz
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


#import "Rule.h"


@implementation Rule 

@dynamic from;
@dynamic to;
@dynamic title;
@dynamic predicate;
@dynamic date;
@dynamic actions;

- (void) awakeFromInsert {
	[super awakeFromInsert];
	[self setDate:[NSDate date]];
	[self setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:
												[NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"kMDItemTextContent = %@", @"Test"]]]];
}

- (BOOL) matches:(NSURL *)url {	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * path = [url absoluteString];
	if (![path hasPrefix: [[self from] url]]) {
		[pool drain];
		return NO;
	}
	
	NSString *queryString = [[self spotifiedPredicate:[self predicate]] predicateFormat];
	MDQueryRef query = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)queryString, NULL, NULL);
	if (!query) {
		DEBUG_OUTPUT(@"Failed to generate query: %@", queryString);
		[pool drain];
		return NO;
	}
	MDQuerySetSearchScope(query, (CFArrayRef) [NSArray arrayWithObject:(id)url], 0);
	MDQueryExecute(query, kMDQuerySynchronous);
	if (MDQueryGetResultCount(query) !=1 ) {
		CFRelease(query);
		query = NULL;
		DEBUG_OUTPUT(@"Spotlight query dit NOT match: %@", queryString);
		[pool drain];
		return NO;
	}
	DEBUG_OUTPUT(@"Spotlight query matched: %@", queryString);
	CFStringRef rel = MDQueryGetAttributeValueOfResultAtIndex(query, kMDQueryResultContentRelevance,0);
	NSLog(@"Relevance: %p",rel);
	CFRelease(query);
	query = NULL;
	[pool drain];
	return YES;
}

-(NSPredicate *) spotifiedPredicate: (id) original {
	if (nil == original) {
		return original;
	}
	if ([original isKindOfClass:[NSCompoundPredicate class]]) {
		NSCompoundPredicateType type = [original compoundPredicateType];
		NSMutableArray *resultingSubPredicates = [NSMutableArray array];
		for (NSPredicate * origSubPredicate in [original subpredicates]) {
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

	} else if ([original isKindOfClass:[NSComparisonPredicate class]] && [original predicateOperatorType] == NSContainsPredicateOperatorType ) {
		return [NSComparisonPredicate predicateWithLeftExpression:[original leftExpression] 
												  rightExpression:[original rightExpression] 
														 modifier:[original comparisonPredicateModifier]
															 type:NSEqualToPredicateOperatorType
														  options:[original options]];
	}
	return original;
}

- (NSURL *) targetURLFor:(NSURL *)file {
	if (file != nil) {
		NSURL *dir = [NSURL URLWithString:[self to]];
		return [dir URLByAppendingPathComponent:[file lastPathComponent]];
	}
	return nil;	
}



@end
