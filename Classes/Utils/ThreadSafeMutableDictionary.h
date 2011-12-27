//
//  ThreadSafeMutableDictionary.h
//  Sorter
//
//  Created by Peter Brachwitz on 13/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface ThreadSafeMutableDictionary : NSMutableDictionary
{
    NSMutableDictionary    *realDictionary;
    NSLock                *lock;
}

@end


