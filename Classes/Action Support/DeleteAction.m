//
//  DeleteAction.m
//  Sorter
//
//  Created by Peter Brachwitz on 17/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeleteAction.h"

@implementation DeleteAction

- (NSURL *) handleItemAt: (NSURL *) url forRule: (Rule *) rule error: (NSError **) error {
    OSStatus status;
    FSRef target;
    FSRef input;
    status = FSPathMakeRef((const UInt8 *)[[url path]fileSystemRepresentation], &input, false);
    assert(status == 0);
    status = FSMoveObjectToTrashSync(&input, &target, kFSFileOperationDefaultOptions);
    if(status == noErr) {
        UInt8 * path[512];
        status = FSRefMakePath(&target, (UInt8 *)path, 512);
        if (status == noErr) {
             NSString * newLocation  = [NSString stringWithUTF8String: (const char *)path];
            return [NSURL fileURLWithPath:newLocation];
        }
    }
    return url;
}

- (NSString *) userDescription {
    return @"Delete";
}

- (NSString *) userConfigDescription {
    return @"item";
    
}
                                      
- (NSView *) settingsView {
    return nil;
}

- (BOOL) valid {
    return YES;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    
    
}
- (id)initWithCoder:(NSCoder *)decoder {
    return [self init];
}
@end
