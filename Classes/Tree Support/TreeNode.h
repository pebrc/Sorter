//
//  TreeNode.h
//  Sorter
//
//  Created by Peter Brachwitz on 02/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeSupport.h"
#import "Source.h"

@interface TreeNode : NSObject <TreeSupport> {
    id backingModel;
    NSMutableArray * children;
}
+ (id<TreeSupport>) nodeWithModel: (id) model;
- (id)initWithModel: (id) model;

@end
