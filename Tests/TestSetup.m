// For iOS
//#import <GHUnitIOS/GHUnit.h> 
// For Mac OS X
#import <GHUnit/GHUnit.h>

@interface TestSetup : GHTestCase { 
    
}
@end

@implementation TestSetup

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES.
    // Also an async test that calls back on the main thread, you'll probably want to return YES.
    return NO;
}

- (void)setUpClass {
}

- (void)tearDownClass {
  }

- (void)setUp {
    
}

- (void)tearDown {
    // Run after each test method
}  

- (void)testFoo {       
}

- (void)testBar {
    // Another test
}

@end