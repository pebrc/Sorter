// For iOS
//#import <GHUnitIOS/GHUnit.h> 
// For Mac OS X
#import <GHUnit/GHUnit.h>
#import "Rule.h"

@interface TestActions : GHTestCase { 
    NSPersistentStoreCoordinator *coord;
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
    NSPersistentStore *store;
    Rule * rule;
}
@end

@implementation TestActions

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return NO;
}

- (void)setUpClass {
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

- (void)tearDownClass {
    [ctx release];
    ctx = nil;
    NSError *error = nil;
    GHAssertTrue([coord removePersistentStore: store error: &error], 
                 @"couldn't remove persistent store: %@", error);
    store = nil;
    [coord release];
    coord = nil;
    [model release];
    model = nil;

}

- (void)setUp {
    // Run before each test method
    rule = [NSEntityDescription insertNewObjectForEntityForName:@"Rule" inManagedObjectContext:ctx];
}

- (void)tearDown {
    // Run after each test method
    [ctx deleteObject:rule];
}  

- (void)testActionsRelationship {       
   NSSet * actions =  [rule actions];
    GHAssertTrue([actions count] == 0, @"there should be no actions", nil);
    
}


- (void)testBar {
    // Another test
}

@end