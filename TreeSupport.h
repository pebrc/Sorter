//
//  TreeSupport.h
//  Sorter
//
//  Created by Peter Brachwitz on 01/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TreeSupport <NSObject>

- (NSMutableArray * ) children;
- (void) setChildren:(NSMutableArray*)newchildren;
- (BOOL) isLeaf;
- (BOOL) isSelectable;
- (NSString*) nodeTitle;
- (id) representedObject;


@end
