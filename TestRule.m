//
//  TestRule.m
//  Sorter
//
//  Created by Peter Brachwitz on 19/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestRule.h"


@implementation TestRule

- (void) setUp {
	model = [[NSManagedObjectModel mergedModelFromBundles: nil] retain];
    NSLog(@"model: %@", model);
    coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
    store = [coord addPersistentStoreWithType: NSInMemoryStoreType
                                configuration: nil
                                          URL: nil
                                      options: nil 
                                        error: NULL];
    ctx = [[NSManagedObjectContext alloc] init];
    [ctx setPersistentStoreCoordinator: coord];
	
}

- (void)tearDown
{
    [ctx release];
    ctx = nil;
    NSError *error = nil;
    STAssertTrue([coord removePersistentStore: store error: &error], 
                 @"couldn't remove persistent store: %@", error);
    store = nil;
    [coord release];
    coord = nil;
    [model release];
    model = nil;
}

- (void) testTargetDirectory {
	NSEntityDescription *ruleEntity = [[model entitiesByName] objectForKey:@"Rule"];
	
	Rule * mover = [[Rule alloc]initWithEntity:ruleEntity insertIntoManagedObjectContext:ctx];
	STAssertNil([mover to], @"getter should return nil");
	[mover release];
}
//- (void) testTargetUrl {
//	Rule * mover = [[Rule alloc]init];
//	NSURL *targetUrl = [mover targetURL];
//	STAssertNil(targetUrl, @"getter should return nil");
//	[mover release];
//}

@end
