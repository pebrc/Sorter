//
//  GrowlDelegate.h
//  Sorter
//
//  Created by Peter Brachwitz on 02/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

typedef enum {
    kPBGrowlImportant,
    kPBGrowlDetailed,
    kPBGrowlChatty = 6

}PBGrowlLevel;

extern NSString * const GrowlSorterMessage;

@interface PBGrowlDelegate : NSObject <GrowlApplicationBridgeDelegate> {
}

+(PBGrowlDelegate *) delegateWithRegistration;
+ (void) notifyWithTitle: (NSString *) title description: (NSString *) description;
+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level: (PBGrowlLevel) level;

@end
