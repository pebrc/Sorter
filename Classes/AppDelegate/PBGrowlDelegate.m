//
//  GrowlDelegate.m
//  Sorter
//
//  Created by Peter Brachwitz on 02/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PBGrowlDelegate.h"
NSString * const GrowlSorterMessage = @"Sorter action";

@implementation PBGrowlDelegate

+(PBGrowlDelegate *) delegateWithRegistration {
    PBGrowlDelegate * obj = [[PBGrowlDelegate alloc] init];
    NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *path = [[mainBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
    NSBundle *growlBundle = [NSBundle bundleWithPath:path];
	if(growlBundle && [growlBundle load]) {
        [GrowlApplicationBridge setGrowlDelegate:obj];
        return [obj autorelease];
    }
    return nil;
}

+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description {
    [PBGrowlDelegate notifyWithTitle:title description:description level:kPBGrowlImportant];
    
}

+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level:(PBGrowlLevel)level {
    NSInteger current = [[NSUserDefaults standardUserDefaults] integerForKey:@"growlPriority"];
    if(level <= current) {
        [GrowlApplicationBridge notifyWithTitle:title description:description notificationName:GrowlSorterMessage iconData:nil priority:0 isSticky:NO clickContext:nil];

    }

}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSDictionary *notificationsWithDescriptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"Sorter triggered an action", GrowlSorterMessage, nil];
    NSArray *allNotifications = [notificationsWithDescriptions allKeys];
    NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Sorter", GROWL_APP_NAME,
							 allNotifications, GROWL_NOTIFICATIONS_ALL,
							 allNotifications,	GROWL_NOTIFICATIONS_DEFAULT,
							 notificationsWithDescriptions,	GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES,
							 nil];
    return regDict;
}


@end
