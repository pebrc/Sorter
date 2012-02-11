//
//  PBMetaDataDateExpression.h
//  Sorter
//
//  Created by Peter Brachwitz on 07/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMetaDataComparisonPredicate.h"
#import "PBMetaDataDateStrategy.h"

@interface PBMetaDataDatePredicate : PBMetaDataComparisonPredicate {
@private
    id<PBMetaDataDateStrategy> strategy;

}

+ (PBMetaDataDatePredicate*) predicateFromPredicate: (NSComparisonPredicate*) predicate;
@end
