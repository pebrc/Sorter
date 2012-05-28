//
//  PBLog.h
//  Sorter
//
//  Created by Peter Brachwitz on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kPBLogError = 1,
    kPBLogInfo = 5,
    kPBLogDebug = 6,
}PBLogLevel;

@interface PBLog : NSObject

+ (void)logDebug: (NSString*) format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void)logInfo: (NSString*) format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void) logError: (NSString*) format, ... NS_FORMAT_FUNCTION(1, 2);

@end
