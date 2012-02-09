//
//  PBMetaDataPredicate.h
//  Sorter
//
//  Created by Peter Brachwitz on 27/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBMetaDataPredicate : NSObject {
@private
    NSPredicate * original;
}

+ (PBMetaDataPredicate *) predicateFromPredicate: (NSPredicate *) source;

- (NSString*) predicateFormat;

@end
