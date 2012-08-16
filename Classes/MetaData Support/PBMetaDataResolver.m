    //
//  PBMetaDataResolver.m
//  Sorter
//
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

#import "PBMetaDataResolver.h"
#import "PBMetaDataPredicate.h"
#import "PBUserNotify.h"

@interface PBMetaDataResolver(PrivateAPI) 
- (NSPredicate*) spotifiedPredicate: (id) original;
- (void) dispose;
@end


@implementation PBMetaDataResolver

- (void) dispose {
    if(self->currentQuery) {
        CFRelease(self->currentQuery);
        self->currentQuery = NULL;
    }
    
}
                

- (void) map: (Rule *) rule toLastResults:(void (^)(NSURL *, Rule *))block {
    if(!self->currentQuery) return;
    MDItemRef item;
    for (long j = 0; j < self->currentResults; j++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        item = (MDItemRef) MDQueryGetResultAtIndex(self->currentQuery, j);
        NSString * path = MDItemCopyAttribute(item, kMDItemPath);
        if(path) {
            NSURL * url = [NSURL fileURLWithPath: path];        
            [path release];
            if([[url absoluteString] rangeOfString:[[rule from]url]].location != NSNotFound) {
                block(url, rule);
            } else {
                [PBUserNotify notifyWithTitle:@"FSEvents Problem" description:[NSString stringWithFormat:@"found %@ outside scope", [url absoluteString]] level:kPBNotifyDebug];
            }
        } else {
            [PBUserNotify notifyWithTitle:@"FSEvents Problem" description:@"FsEvents returned nil path" level:kPBNotifyDebug];

        }        
        [pool release];        
    }
    [self dispose];
}

- (BOOL) predicate:(NSPredicate *)expression matches:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	NSString *queryString =  [[PBMetaDataPredicate predicateFromPredicate:expression] predicateFormat];
	self->currentQuery = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)queryString, NULL, NULL);
    [PBUserNotify notifyWithTitle:@"Creating query" description:queryString level:kPBNotifyDebug];
	if (!self->currentQuery) {
        [PBUserNotify notifyWithTitle:@"Failed to generate query" description:queryString level:kPBNotifyError];
		[pool drain];
		return NO;
	}
	MDQuerySetSearchScope(self->currentQuery, (CFArrayRef) [NSArray arrayWithObject:(id)url], 0);
	MDQueryExecute(self->currentQuery, kMDQuerySynchronous);
    self->currentResults = MDQueryGetResultCount(self->currentQuery); 
    if(self->currentResults == 0) {
        [self dispose];
        [PBUserNotify notifyWithTitle:@"Spotlight query did NOT match" description:[NSString stringWithFormat:@"Url: %@ , query was: %@", url, queryString] level:kPBNotifyInfo];
		[pool drain];
		return NO;
    }
    [pool drain];
    return YES;
    
    
}




@end
