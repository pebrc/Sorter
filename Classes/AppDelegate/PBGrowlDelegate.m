//Copyright (c) 2012 Peter Brachwitz
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

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
