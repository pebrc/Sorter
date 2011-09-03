// For iOS
//#import <GHUnitIOS/GHUnit.h> 
// For Mac OS X
#import <GHUnit/GHUnit.h>
#import "MoveAction.h"
#import "Transformers.h"
#import "Action.h"

@interface TestActionsNoDB : GHTestCase { 
}
@end

@implementation TestActionsNoDB

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return NO;
}




-(void) testActionTransformer {
    MoveAction * a = [[MoveAction alloc]init];
    ActionStrategyTransformer * t = [[ActionStrategyTransformer alloc ]init];
    id result = [t transformedValue:a];
    GHAssertTrue([result isKindOfClass: [NSData class]], @"Should be NSData now",nil);
    id newStrategy = [t reverseTransformedValue:result];
    GHAssertTrue([newStrategy isMemberOfClass: [MoveAction class]], @"Must be a Move action",nil);
    GHAssertTrue(a != newStrategy, @"Should be different objects now", nil);
  //  [a release];
    //[t release];
    //[newStrategy release];
    
    
    
    
}

- (void) testActionEnumeration {
    NSSet * actions = [Action availableActions];
    GHAssertTrue([actions count] == 1, @"one action strategy implemented");
    GHAssertTrue([actions  containsObject:[MoveAction class]], @"Should contain move action");
}

@end