//
//  LeafNode.h
//  Sorter
//
//  Created by Peter Brachwitz on 04/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"
#import "Rule.h"


@interface LeafNode : TreeNode {
@private
        NSMutableArray * treeSupportDummy;
}

@end
