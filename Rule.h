//
//  Rule.h
//  Sorter
//
//  Created by Peter Brachwitz on 14/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Source.h"


@interface Rule :  NSManagedObject  
{
}

@property (nonatomic, retain) Source * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSPredicate * predicate;
@property (nonatomic, retain) NSDate * date;
- (BOOL) matches:(NSURL *) url;
- (NSURL*) targetURLFor: (NSURL *) file;
- (NSPredicate*) spotifiedPredicate: (id) original;

@end



