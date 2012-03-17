//
//  DeleteAction.m
//  Sorter
//
//  Created by Peter Brachwitz on 17/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeleteAction.h"

@implementation DeleteAction

- (BOOL) handleItemAt: (NSURL *) url forRule: (Rule *) rule error: (NSError **) error {
    [[NSWorkspace sharedWorkspace]recycleURLs:[NSArray arrayWithObject:url] completionHandler:nil];
    return YES;
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
