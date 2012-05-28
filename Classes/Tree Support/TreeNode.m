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
    [children release];
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
    return [[[(Source*)backingModel url]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
}

@end
