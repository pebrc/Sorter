//Copyright (c) 2011 Peter Brachwitz
// With some inspiration from SCEvents Copyright (c) 2009 Stuart Connolly
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


#import "PBEvent.h"

NSString * const PBEventName = @"PBEventName";

@implementation PBEvent

@synthesize eventDate,eventPath, eventId, eventFlags;

-(id) initWithId:(FSEventStreamEventId)fsEventId date:(NSDate *)date path:(NSString *)path eventFlags:(FSEventStreamEventFlags)flags {
	self = [super init];
	if(self != nil) {
		[self setEventId: fsEventId];
		[self setEventPath:path];
		[self setEventDate:date];
		[self setEventFlags:flags];
	}
	return self;
}

- (NSString *) description {
    FSEventStreamEventId flags = eventFlags;
    NSMutableArray * flagDescriptions = [NSMutableArray array];
    if(flags & kFSEventStreamEventFlagMustScanSubDirs) {
        [flagDescriptions addObject:@"Must scan subdirs"];
        if(flags & kFSEventStreamEventFlagUserDropped) {
            [flagDescriptions addObject:@"because client dropped events."];
        }
        if(flags & kFSEventStreamEventFlagKernelDropped) {
            [flagDescriptions addObject:@"because kernel dropped events."];
        }
    }
    if(flags & kFSEventStreamEventFlagEventIdsWrapped) {
        [flagDescriptions addObject:@"Id counter wrapped around."];
    }
    if (flags & kFSEventStreamEventFlagHistoryDone) {
        [flagDescriptions addObject:@"History replay done."];
    }
    if (flags & kFSEventStreamEventFlagRootChanged) {
        [flagDescriptions addObject:@"Root directory above watched path changed."];
    }
    if (flags & kFSEventStreamEventFlagMount) {
        [flagDescriptions addObject:@"Mount happened in monitored path."];
    }
    if (flags & kFSEventStreamEventFlagUnmount) {
        [flagDescriptions addObject:@"Unmount happened in monitored path."];
    }
    if (flags & kFSEventStreamEventFlagItemCreated) {
        [flagDescriptions addObject:@"An item has been created."];
    }
    if (flags & kFSEventStreamEventFlagItemRemoved) {
        [flagDescriptions addObject:@"An item has been removed."];
    }
    if (flags & kFSEventStreamEventFlagItemInodeMetaMod) {
        [flagDescriptions addObject:@"Inode metadata has been modified."];
    }
    if (flags & kFSEventStreamEventFlagItemRenamed) {
        [flagDescriptions addObject:@"An item has been renamed."];
    }
    if (flags & kFSEventStreamEventFlagItemModified) {
        [flagDescriptions addObject:@"An item has been modified."];
    }
    if (flags & kFSEventStreamEventFlagItemFinderInfoMod) {
        [flagDescriptions addObject:@"An item's finder info has been modified."];
    }
    if (flags & kFSEventStreamEventFlagItemChangeOwner) {
        [flagDescriptions addObject:@"An item has changed owner."];
    }
    if (flags & kFSEventStreamEventFlagItemXattrMod) {
        [flagDescriptions addObject:@"An item's xattrs have been modified."];
    }
    if (flags & kFSEventStreamEventFlagItemIsFile) {
        [flagDescriptions addObject:@"The item is a file."];
    }
    if (flags & kFSEventStreamEventFlagItemIsDir) {
        [flagDescriptions addObject:@"The item is a directory."];
    }
    if (flags & kFSEventStreamEventFlagItemIsSymlink) {
        [flagDescriptions addObject:@"The item is a symlink."];
    }
    return [NSString stringWithFormat:@"id: %llu, path: %@, date: %@, %@", eventId, eventPath, [eventDate description],     [flagDescriptions componentsJoinedByString:@" "]];

}

-(void) dealloc {
    [eventPath release];
    [eventDate release];
    [super dealloc];
}
@end
