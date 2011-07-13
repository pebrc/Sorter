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


#import "Transformers.h"
NSString * const TransformationSideEffect = @"TransformationSideEffect";

@implementation SourceLocationTransformer
@synthesize managedObjectContext;

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL) allowsReverseTransformation {
	return YES;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)context {
	self = [super init]; 
	if (self != nil) {
		[self setManagedObjectContext:context];
	}
	return self;
}

- (id) transformedValue:(id)value {
	if ([value isMemberOfClass:[Source class]] && [[[value entity] name] isEqual:@"Source"]) {
		return [[value valueForKeyPath:@"self.url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	return @"";
}

- (id) reverseTransformedValue:(id)value {
	if (![value isKindOfClass:[NSString class]]) {
		[NSException raise:NSInvalidArgumentException format:@"Argument must be an instance of NSString"];
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	if(nil == moc) {
		[NSException raise:NSInternalInconsistencyException format:@"No managed object context available"];
	}
	NSEntityDescription *source = [NSEntityDescription entityForName:@"Source" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc]init] autorelease];
	[request setEntity:source];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url = %@", value];
	[request setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [moc executeFetchRequest:request error:&error];
	if(array == nil) {
				[NSException raise:NSInternalInconsistencyException format:@"Fetch request failed"];
	} else if ([array count] == 0) {
		NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Source" 
														  inManagedObjectContext: moc];
		[newObject setValue:value forKey:@"url"];
		return newObject;
		
	}
    NSNotification *n =
    [NSNotification notificationWithName:TransformationSideEffect object:[array objectAtIndex:0]];
    [[NSNotificationQueue defaultQueue] 
     enqueueNotification:n 
     postingStyle:NSPostASAP 
     coalesceMask:NSNotificationCoalescingOnName 
     forModes:nil];
	return [array objectAtIndex:0];
	
		
}




@end
