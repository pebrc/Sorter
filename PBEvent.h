//
//  PBEvent.h
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBEventListener.h"
#import "PBWatcher.h"

extern NSString * const PBEventName;

@interface PBEvent : NSObject {
    NSUInteger eventId;
    NSDate *eventDate;
    NSString *eventPath;
    FSEventStreamEventFlags eventFlags;
}

@property (readwrite, assign) NSUInteger eventId;
@property (readwrite, retain) NSDate *eventDate;
@property (readwrite, retain) NSString *eventPath;
@property (readwrite, assign) FSEventStreamEventFlags eventFlags;

- (id) initWithId: (NSUInteger) fsEventId date: (NSDate *) date path: (NSString *) path eventFlags: (FSEventStreamEventFlags) flags;


@end
