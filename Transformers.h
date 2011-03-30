//
//  Transformers.h
//  Sorter
//
//  Created by Peter Brachwitz on 03/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Source.h"


@interface SourceLocationTransformer : NSValueTransformer {

	NSManagedObjectContext * managedObjectContext;
}
@property (nonatomic,retain) NSManagedObjectContext * managedObjectContext;
- (id) initWithManagedObjectContext:(NSManagedObjectContext *) context;
@end
