//
//  PBNotificationCenterDelegate.m
//  Sorter
//
//  Created by Peter Brachwitz on 16/08/2012.
//
//

#import "PBNotificationCenterDelegate.h"

@implementation PBNotificationCenterDelegate


+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level:(PBNotifyLevel)level {
    NSInteger current = [[NSUserDefaults standardUserDefaults] integerForKey:@"growlPriority"];
    if(level > current) {
        return;
    }
    NSUserNotificationCenter * center = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSUserNotification * msg = [[[NSUserNotification alloc] init] autorelease];
    [msg setTitle:title];
    [msg setSubtitle:description];
    [center scheduleNotification:msg];
}

@end
