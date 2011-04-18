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

@interface RuleHandler(PrivateApi)
+(BOOL) handleURL:(NSURL *)url fromSource:(Source *)source ignoringDirs: (BOOL) nodescent depth:(int)num;
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

+ (BOOL) handleFileRepresentedByString: (NSString *) string {
	NSURL * url = [NSURL URLWithString:string];
	return	[RuleHandler handleFileRepresentedByURL:url];
	
}

+ (BOOL) handleSource:(Source *)source {
	NSURL * url = [NSURL URLWithString:[source url]];
    return [RuleHandler handleURL:url fromSource:source skipDirs:NO];
}


+ (BOOL) handleURL:(NSURL *)url fromSource:(Source *)source ignoringDirs:(BOOL)nodescent depth:(int)num {
    NSFileManager * manager = [NSFileManager defaultManager];

	BOOL isDir;
	url = [RuleHandler normalizeURL: url checkIfDirectory: &isDir];
	if (nil == url) {		
		DEBUG_OUTPUT(@"File does not %@",@"exist");		
		return NO;
	}
	
	if (isDir && (num < 1|| !nodescent) ) {
        
		NSDirectoryEnumerator *iter = [manager enumeratorAtURL:url
									includingPropertiesForKeys:NULL 
													   options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
												  errorHandler:^(NSURL *url, NSError *error) {
													  return YES;
												  }];
		BOOL result = YES;
        num++;
		for(NSURL *subURL in iter) {
			result &= [RuleHandler handleURL:subURL fromSource:source ignoringDirs:nodescent depth:num];
		}
		return result;
	}
	
	DEBUG_OUTPUT(@"Handling file %@", [url absoluteURL]);
	
	
	
	Rule *rule = [RuleHandler matchingRuleOf:[source rules] ForURL:url];
	if (rule == nil) {
		return NO;
	}
	DEBUG_OUTPUT(@"Target: %@",[[rule to] description] );
	NSError *error = nil;
	BOOL success = [manager moveItemAtURL:url toURL:[rule targetURLFor:url]  error:&error];
	if (!success) {
		NSLog(@"%@:%@ Error moving file: %@", [RuleHandler class], NSStringFromSelector(_cmd), [error localizedDescription]);
		return NO;
	}
	return success;
	

}

+ (BOOL) handleURL: (NSURL*) url fromSource:(Source *)source skipDirs:(BOOL)value {
    dispatch_async([RuleHandler queue], ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [RuleHandler handleURL:url fromSource:source ignoringDirs:value depth:0];
        [pool drain];
        
    });
	return YES;
}

+ (Source *) matchingSourceFor: (NSURL *) url {
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Source" inManagedObjectContext:moc]];
	NSError *error = nil;
	NSArray *fetchedSources = [moc executeFetchRequest:request error:&error];
	NSString * absoluteString = [url absoluteString];
    [request release];
	if (fetchedSources != nil) {
		for (id source in fetchedSources) {
			if ([absoluteString hasPrefix:[(Source*)source url]]) {
				return source;
			}
		}
	}	
	return nil;
	
}

+ (BOOL) handleFileRepresentedByURL:(NSURL *)url {
	
	Source *source = [RuleHandler matchingSourceFor:url];
	if (source == nil) {
		return NO;
	}
	return [RuleHandler handleURL:url fromSource:source skipDirs:YES];
	
}

+ (NSURL*) normalizeURL:(NSURL*) url checkIfDirectory:(BOOL *) isDir {
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

+ (Rule *) matchingRuleOf: (NSSet*) rules ForURL:(NSURL *)url {
	for(id rule in rules) {
		if ([rule matches:url]) {
			return rule;
		}
	}
	return nil;
	
}


@end
