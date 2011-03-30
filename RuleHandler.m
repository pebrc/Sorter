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


@implementation RuleHandler

+ (BOOL) handleFileRepresentedByString: (NSString *) string {
	NSURL * url = [NSURL URLWithString:string];
	return	[RuleHandler handleFileRepresentedByURL:url];
	
}

+ (BOOL) handleSource:(Source *)source {
	NSURL * url = [NSURL URLWithString:[source url]];
	return [RuleHandler handleURL:url fromSource:source];
}

+ (BOOL) handleURL: (NSURL*) url fromSource:(Source *)source {
	NSFileManager * manager = [NSFileManager defaultManager];
	
	BOOL isDir;
	url = [RuleHandler normalizeURL: url checkIfDirectory: &isDir];
	if (nil == url) {		
		DEBUG_OUTPUT(@"File does not exist", nil);		
		return NO;
	}
	
	if (isDir) {
		NSDirectoryEnumerator *iter = [manager enumeratorAtURL:url
									includingPropertiesForKeys:NULL 
													   options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
												  errorHandler:^(NSURL *url, NSError *error) {
													  return YES;
												  }];
		BOOL result = YES;
		for(NSURL *subURL in iter) {
			result &= [RuleHandler handleURL:subURL fromSource:source];
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
		NSLog(@"%@:%s Error moving file: %@", [RuleHandler class], _cmd, [error localizedDescription]);
		return NO;
	}
	return success;
	
	
}

+ (Source *) matchingSourceFor: (NSURL *) url {
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:@"Source" inManagedObjectContext:moc]];
	NSError *error = nil;
	NSArray *fetchedSources = [moc executeFetchRequest:request error:&error];
	NSString * absoluteString = [url absoluteString];
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
	return [RuleHandler handleURL:url fromSource:source];
	
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
