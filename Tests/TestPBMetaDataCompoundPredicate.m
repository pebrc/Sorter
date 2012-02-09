//
//  TestPBMetaDataCompoundPredicate.m
//  Sorter
//
//  Created by Peter Brachwitz on 08/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestPBMetaDataCompoundPredicate.h"
#import "PBMetaDataPredicate.h"

@implementation TestPBMetaDataCompoundPredicate

// All code under test must be linked into the Unit Test bundle
- (void)testAndPredicateIsCStyle
{
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"kMDItemTextContent == 'Foo' AND kMDItemTextContent == 'Bar'"];
    PBMetaDataPredicate * modified = [PBMetaDataPredicate predicateFromPredicate:pred];
    STAssertEqualObjects([modified predicateFormat], @"kMDItemTextContent == \"Foo\" && kMDItemTextContent == \"Bar\"", @"AND is c-style in spotlight");
}

- (void)testOrPredicateIsCStyle
{
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"kMDItemTextContent == 'Foo' OR kMDItemTextContent == 'Bar'"];
    PBMetaDataPredicate * modified = [PBMetaDataPredicate predicateFromPredicate:pred];
    STAssertEqualObjects([modified predicateFormat], @"kMDItemTextContent == \"Foo\" || kMDItemTextContent == \"Bar\"", @"AND is c-style in spotlight");
}


@end
