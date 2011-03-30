//
//  Rule.h
//  Sorter
//
//  Created by Peter Brachwitz on 14/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Rule :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * predicate;
@property (nonatomic, retain) NSDate * date;

@end



