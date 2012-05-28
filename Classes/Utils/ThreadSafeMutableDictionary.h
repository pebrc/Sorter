//
//  ThreadSafeMutableDictionary.h
//  Technical Note TN2059
//

#import <Cocoa/Cocoa.h>
@interface ThreadSafeMutableDictionary : NSMutableDictionary
{
    NSMutableDictionary    *realDictionary;
    NSLock                *lock;
}

@end


