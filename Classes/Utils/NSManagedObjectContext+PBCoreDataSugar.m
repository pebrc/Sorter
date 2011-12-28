//
//  NSManagedObjectContext+PBCoreDataSugar.m
//  Sorter
//
//  Created by Peter Brachwitz on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObjectContext+PBCoreDataSugar.h"

@implementation NSManagedObjectContext (PBCoreDataSugar)

-(NSArray *) fetchAll:(NSString *)entities {
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSError * error = nil;
	[request setEntity:[NSEntityDescription entityForName:@"Source" inManagedObjectContext:self]];
	NSArray *fetchedSources = [self executeFetchRequest:request error:&error];
    [request release]; request = nil;
	return fetchedSources;
}

@end
