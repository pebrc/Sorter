//
//  NSManagedObjectContext+PBCoreDataSugar.h
//  Sorter
//
//  Created by Peter Brachwitz on 28/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (PBCoreDataSugar)

-(NSArray *) fetchAll:(NSString *) entities;

@end
