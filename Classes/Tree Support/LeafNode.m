//
//  LeafNode.m
//  Sorter
//
//  Created by Peter Brachwitz on 04/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
