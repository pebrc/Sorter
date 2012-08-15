//Copyright (c) 2011 Peter Brachwitz
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


#import "Source.h"
#import "RuleHandler.h"
#import "PBGrowlDelegate.h"
#import "PBLog.h"

@implementation Source 

@dynamic url;
@dynamic rules;
@dynamic eventid;
@dynamic bookmark;



- (void) awakeFromInsert {
    [super awakeFromInsert];
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"url"]) {
        id  path = [change valueForKey:@"new"];
        if(path == [NSNull null]) {
            return;
        }
            
        NSURL * url  = [NSURL URLWithString:path];
        NSError * err = nil;
        [self setBookmark:[url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&err]];
    }
}




-(void) event:(PBEvent*)event reportedBy:(PBWatcher*)watcher {
	NSURL * url = [NSURL URLWithString:[event eventPath]];
    //remember the event even if we are going to drop it
    DEBUG_OUTPUT(@"Before: %llu", [self lastListened]);
    NSNumber * currentEvent = [NSNumber numberWithUnsignedLongLong:[event eventId]];
    if([currentEvent isEqualToNumber:[self eventid]]) {
        DEBUG_OUTPUT(@"Dropping event on url %@ because eventid %llu is identical to last eventid",url, [event eventId]);
        return;
    }
    [self setEventid: currentEvent];
    NSString * eventDesc = [event description];
    [PBGrowlDelegate notifyWithTitle:@"FS Event" description:eventDesc level:kPBGrowlChatty]; 
    [PBLog logDebug:@"%@", eventDesc];

    if(![[NSFileManager defaultManager]fileExistsAtPath:[url path]]) {
        DEBUG_OUTPUT(@"Dropping event on url %@ because file does not seem to exist", url);
        return;
    }
    //TODO: kFSEventStreamEventFlagRootChanged
	[RuleHandler handleURL:url fromSource:self withFlags:[event eventFlags]];
}

-(FSEventStreamEventId) lastListened {
    return [[self eventid] unsignedLongLongValue];
}

- (NSURL*) securityScope {
    BOOL stale;
    NSError * err;
    return [NSURL URLByResolvingBookmarkData:[self bookmark] options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:&stale error:&err];
}



@end
