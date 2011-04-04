//
//  PBEvent.m
//  Sorter
//
//  Created by Peter Brachwitz on 05/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
@end
