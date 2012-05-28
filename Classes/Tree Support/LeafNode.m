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

#import "LeafNode.h"


@implementation LeafNode

- (id)initWithModel:(id)model
{
    self = [super init];
    if (self) {
        if(![model isMemberOfClass:[Rule class]]) {
            [self release];
            return nil;
        }
        backingModel = model;
        [backingModel retain];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


-(NSMutableArray *) children {
    if(!treeSupportDummy) {
        treeSupportDummy = [NSMutableArray arrayWithCapacity:0];
    }
    return treeSupportDummy;
}

-(void) setChildren: (NSMutableArray *) children {
    NSException * e = [NSException exceptionWithName:NSIllegalSelectorException reason:@"Cannot set children on leaf node" userInfo:nil];
    @throw e;
}

-(BOOL) isLeaf {
    return YES;
}

- (BOOL) isSelectable {
    return YES;
}


-(NSString*) nodeTitle {
    return [backingModel title];
}

-(void) setNodeTitle:(NSString *) title {
    [backingModel setTitle:title];
}



@end
