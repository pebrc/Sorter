//
//  PBLog.m
//  Sorter
//
//  Created by Peter Brachwitz on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBLog.h"

void pblog(PBLogLevel level, NSString * format, va_list params) {
    NSInteger current = [[NSUserDefaults standardUserDefaults] integerForKey:@"logLevel"];
    if(level <= current){
        NSLogv(format, params);  
    }
}

@implementation PBLog

+(void)logDebug:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    pblog(kPBLogDebug, format, args );
    va_end(args);
}

+(void) logError:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    pblog(kPBLogError, format, args );
    va_end(args);
}

+(void) logInfo:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    pblog(kPBLogInfo, format, args );
    va_end(args);
}
@end
