//
//  PBAbstractDateStrategy.h
//  Sorter
//
//  Created by Peter Brachwitz on 11/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMetaDataDateStrategy.h"
@interface PBAbstractDateStrategy : NSObject < PBMetaDataDateStrategy >

-(NSString *) trimmedLhsOf:(PBMetaDataComparisonPredicate*) predicate;
-(NSDate *) representedDateIn:(PBMetaDataComparisonPredicate*) predicate;
@end
