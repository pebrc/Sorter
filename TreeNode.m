//
//  TreeNode.m
//  Sorter
//
//  Created by Peter Brachwitz on 02/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TreeNode.h"
#import "Rule.h"
#import "LeafNode.h"

@implementation TreeNode


+ (id<TreeSupport>) nodeWithModel:(id)model {
        //quick and dirty factory
    if([model isMemberOfClass:[Source class]]) {
        TreeNode * obj = [[[TreeNode alloc] initWithModel:model] autorelease];
        return obj;
    } else if ([model isMemberOfClass:[Rule class]]) {
        LeafNode * obj = [[[LeafNode alloc]initWithModel:model]autorelease];
        return obj;
    }
    return nil;
}

- (id)initWithModel: (id) model
{
    self = [super init];
    if (self) {
        if(![model isMemberOfClass:[Source class]]) {
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
    [backingModel release]; backingModel = nil;
    [super dealloc];
}

- (id) representedObject {
    return backingModel;
}


-(NSMutableArray *) children {
    if(children == nil) {
        NSMutableArray * result = [NSMutableArray arrayWithCapacity:[[backingModel rules]count]];
        for( id rule in [backingModel rules]) {
            [result addObject:[TreeNode nodeWithModel:rule]];
        }
        [result retain];
        children =  result;
    }
    return children;
}


-(void) setChildren:(NSMutableArray *) newchildren {
    if(children != newchildren) {
        NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:[newchildren count]];
        for (id node in newchildren) {
            [tmp addObject: [node representedObject]];
        }
        NSSet *childset = [NSSet setWithArray:tmp];
        [children release];
         children = [NSMutableArray arrayWithArray:newchildren];
        [children retain];
        [backingModel setRules:childset];
    }
    
}

-(BOOL) isLeaf {
    return [[backingModel rules]count] == 0;
}

- (BOOL) isSelectable {
    return NO;
}

-(NSString * ) nodeTitle {
    return [(Source*)backingModel url];
}

@end
