//
//  Transformers.m
//  Sorter
//
//  Created by Peter Brachwitz on 03/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Transformers.h"


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
		return [value valueForKeyPath:@"self.url"];
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
	return [array objectAtIndex:0];
	
		
}




@end
