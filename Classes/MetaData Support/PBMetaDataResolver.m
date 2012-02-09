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
        NSURL * url = [NSURL fileURLWithPath: path];
        [path release];
        block(url, rule);
        [pool release];        
    }
    [self dispose];
}

- (BOOL) predicate:(NSPredicate *)expression matches:(NSURL *)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	NSString *queryString =  [[PBMetaDataPredicate predicateFromPredicate:expression] predicateFormat];
	self->currentQuery = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)queryString, NULL, NULL);
    DEBUG_OUTPUT(@"Creating query: %@", queryString);
	if (!self->currentQuery) {
		DEBUG_OUTPUT(@"Failed to generate query: %@", queryString);
		[pool drain];
		return NO;
	}
	MDQuerySetSearchScope(self->currentQuery, (CFArrayRef) [NSArray arrayWithObject:(id)url], 0);
	MDQueryExecute(self->currentQuery, kMDQuerySynchronous);
    self->currentResults = MDQueryGetResultCount(self->currentQuery); 
    if(self->currentResults == 0) {
        [self dispose];
        DEBUG_OUTPUT(@"Spotlight query in %@ did NOT match: %@", url, queryString);
		[pool drain];
		return NO;
    }
    [pool drain];
    return YES;
    
    
}




@end
