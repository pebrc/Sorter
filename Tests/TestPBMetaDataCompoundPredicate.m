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
