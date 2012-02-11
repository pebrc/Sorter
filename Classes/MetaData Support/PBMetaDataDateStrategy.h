//
//  PBMetaDataDateStrategy.h
//  Sorter
//
//  Created by Peter Brachwitz on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMetaDataComparisonPredicate.h"

@protocol PBMetaDataDateStrategy <NSObject>

-(BOOL) canHandlePredicate:(NSComparisonPredicate*) predicate;
-(NSString *) predicateFormatFor: (PBMetaDataComparisonPredicate*) predicate ;

@end
