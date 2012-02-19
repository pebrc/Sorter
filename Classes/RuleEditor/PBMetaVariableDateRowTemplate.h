//
//  PBMetaDateRowTemplate.h
//  Sorter
//
//  Created by Peter Brachwitz on 30/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PBMetaVariableDateRowTemplate : NSPredicateEditorRowTemplate 

@property (readonly) NSArray* persistedOperators;
@property (readonly) NSDictionary* metaDataVariables;

- (id) initWithLeftExpressions:(NSArray *)leftExpressions;


@end
