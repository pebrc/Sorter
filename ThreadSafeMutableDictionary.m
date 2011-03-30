//
//  ThreadSafeMutableDictionary.m
//  Technical Note TN2059
//

#import "ThreadSafeMutableDictionary.h"


@implementation ThreadSafeMutableDictionary : NSMutableDictionary

//  Primitive methods in NSDictionary

- (NSUInteger) count;
{
    //  I believe we don't need to lock for this.
    return [realDictionary count];
}

- (NSEnumerator *) keyEnumerator;
{
    NSEnumerator    *result;
	
    //    It's not clear whether we need to lock for this operation,
    //    but let's be careful.
    [lock lock];
    result = [realDictionary keyEnumerator];
    [lock unlock];
	
    return result;
}

- (id) objectForKey: (id) aKey;
{
    id    result;
	
    [lock lock];
    result = [realDictionary objectForKey: aKey];
	
    //    Before unlocking, make sure this object doesn't get
    //  deallocated until the autorelease pool is released.
    [[result retain] autorelease];
    [lock unlock];
	
    return result;
}


//  Primitive methods in NSMutableDictionary
- (void) removeObjectForKey: (id) aKey;
{
    //    While this method itself may not run into trouble, respect the
    //  lock so we don't trip up other threads.
    [lock lock];
    [realDictionary removeObjectForKey: aKey];
    [lock unlock];
}

- (void) setObject: (id) anObject forKey: (id) aKey;
{
    //    Putting the object into the dictionary puts it at risk for being
    //  released by another thread, so protect it.
    [[anObject retain] autorelease];
	
    //    Respect the lock, because setting the object may release
    // its predecessor.
    [lock lock];
    [realDictionary setObject: anObject  forKey: aKey];
    [lock unlock];
}


//    This isn't labeled as primitive, but let's optimize it.
- (id) initWithCapacity: (NSUInteger) numItems;
{
    self = [self init];
    if (self != nil)
        realDictionary = [[NSMutableDictionary alloc] initWithCapacity: numItems];
	
    return self;
}

//    Overrides from NSObject
- (id) init;
{
    self = [super init];
    if (self != nil)
        lock = [[NSLock alloc] init];
	
    return self;
}

- (void) dealloc;
{
    [realDictionary release];
    [lock release];
	
    [super dealloc];
}

@end
