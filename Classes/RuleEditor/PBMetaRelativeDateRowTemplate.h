//
//  PBMetaRelativeDateRowTemplate.h
//  Sorter
//
//  Created by Peter Brachwitz on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//   http://funwithobjc.tumblr.com/post/1677163679/creating-an-advanced-nspredicateeditorrowtemplate
//

#import <Foundation/Foundation.h>

@interface PBMetaRelativeDateRowTemplate : NSPredicateEditorRowTemplate {
    NSPopUpButton * unitPopUpButton;
    NSArray * lastScanned;
    NSInteger lastNumUnits;
    NSString * lastUnit;
    NSArray * persistedOperators;
    NSDictionary* significantPart;

}
@property (readonly) NSArray* persistedOperators;
@property (readonly) NSDictionary* significantPart;

- (id) initWithLeftExpressions:(NSArray *)leftExpressions;

@end
