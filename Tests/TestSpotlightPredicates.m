//
//  TestSpotlightPredicates.m
//  Sorter
//
//  Created by Peter Brachwitz on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TestSpotlightPredicates.h"
#import "PBMetaDataPredicate.h"

@interface PBMetaDataPredicate(Exposing) 
- (id) initWithPredicate: (NSPredicate*) original;
- (NSPredicate*) spotifiedPredicate: (NSPredicate*) source;
@end

@implementation TestSpotlightPredicates

// All code under test must be linked into the Unit Test bundle

- (void) testContainsBecomesEqualsWildcard
{
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"kMDItemTextContent CONTAINS %@", @"Bawag"];
    PBMetaDataPredicate * res = [PBMetaDataPredicate predicateFromPredicate: pred];
    STAssertTrue([[res predicateFormat] isEqualTo: @"kMDItemTextContent == \"*Bawag*\""], @"CONTAINS should be transformed to wildcard expression, but was %@", [res predicateFormat]);
    pred = [NSPredicate predicateWithFormat:@"kMDItemTextContent CONTAINS %@", @"Postbank"];
    res = [PBMetaDataPredicate predicateFromPredicate: pred];
    STAssertTrue([[res predicateFormat] isEqualToString: @"kMDItemTextContent == \"*Postbank*\""], @"CONTAINS should be transformed to wildcard expression, but was %@", [res predicateFormat]);
    
}

- (void) testComparisonModifiersAreOnTheValue {
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"kMDItemTextContent CONTAINS[cd] %@", @"Bawag"];
    PBMetaDataPredicate * res = [PBMetaDataPredicate predicateFromPredicate: pred];
    STAssertTrue([[res predicateFormat] isEqualTo: @"kMDItemTextContent == \"*Bawag*\"cd"], @"CONTAINS should be transformed to wildcard expression, but was %@", [res predicateFormat]);

}

@end
