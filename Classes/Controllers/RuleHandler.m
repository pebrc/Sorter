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

#import "RuleHandler.h"
#import "Rule.h"
#import "PBMetaDataResolver.h"
#include <dispatch/dispatch.h>


@interface RuleHandler(PrivateApi)
+(BOOL) handleURL:(NSURL *)url fromSource:(Source *)source ignoringDirs: (BOOL) nodescent ;
+(BOOL) handleURL:(NSURL *)url fromSourceId:(NSManagedObjectID *)oid ignoringDirs: (BOOL) nodescent  with:(NSPersistentStoreCoordinator *)psc;
+(dispatch_queue_t) queue;
@end

static dispatch_queue_t localqueue = nil;

@implementation RuleHandler

+ (dispatch_queue_t) queue {
    if (localqueue == nil) {
        localqueue = dispatch_queue_create("com.blogspot.pbrc", NULL);
    }
    return localqueue;
}


+ (BOOL) handleSource:(Source *)source {
	NSURL * url = [NSURL URLWithString:[source url]];
    return [RuleHandler handleURL:url fromSource:source skipDirs:NO];
}

+ (BOOL) handleURL:(NSURL *)url fromSource:(Source *)source ignoringDirs:(BOOL)nodescent {
    BOOL res = YES;
    PBMetaDataResolver *resolver = [[PBMetaDataResolver alloc] init];
    for(id rule in [[source rules] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"active = TRUE AND actions.@count > 0"]]) {
		if ([resolver predicate:[rule predicate] matches:url ]) {
            [resolver map: rule toLastResults: ^(NSURL * url, Rule* rule){
                for(Action *a in [rule actions]) {
                    NSError *error = nil;
                    BOOL success = [a handleItemAt:url error:&error];
                    if (!success) {
                        NSLog(@"%@:%@ Error in action for file: %@", [RuleHandler class], NSStringFromSelector(_cmd), [error localizedDescription]);
                    } 
                    
                }
            }];
		}
	}
    [resolver release];
	return res;

    
}



+ (BOOL) handleURL: (NSURL*) url fromSource:(Source *)source skipDirs:(BOOL)value {
    NSPersistentStoreCoordinator *psc = [[source managedObjectContext] persistentStoreCoordinator];
    NSManagedObjectID *oid  = [source objectID];
    dispatch_async([RuleHandler queue], ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [RuleHandler handleURL:url fromSourceId:oid ignoringDirs:value with:psc];
        [pool drain];
        
    });
	return YES;
}

+ (BOOL) handleURL:(NSURL *)url fromSourceId:(NSManagedObjectID *)oid ignoringDirs:(BOOL)nodescent with:(NSPersistentStoreCoordinator *)psc {
     NSManagedObjectContext * managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: psc];
    Source * src = (Source *)[managedObjectContext objectWithID:oid];
    return [RuleHandler handleURL:url fromSource:src ignoringDirs:nodescent];
}



+ (NSURL*) normalizeURL:(NSURL*) url checkIfDirectory:(BOOL *) isDir {
    if(nil == url) {
        return  url;
    }
	DEBUG_OUTPUT(@"%@", [url description]);
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL ok = [manager fileExistsAtPath:[url path] isDirectory: isDir];
	if (!ok) {
		DEBUG_OUTPUT(@"Normalizing url: %@", [url absoluteString]);
		NSURL *dir = [NSURL URLWithString:[manager currentDirectoryPath]];
		url =  [dir URLByAppendingPathComponent:[url relativeString]];
		if (![manager fileExistsAtPath:[url absoluteString] isDirectory: isDir]) {
			return nil;
		}
	}
	return url;
	
}




@end
