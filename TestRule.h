//
//  TestRule.h
//  Sorter
//
//  Created by Peter Brachwitz on 19/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Rule.h"

@interface TestRule : SenTestCase {
	NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
}

@end
