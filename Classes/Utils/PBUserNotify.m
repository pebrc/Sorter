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


#import "PBUserNotify.h"

@interface PBUserNotify(PrivateAPI)
- (void) notifyDelegatesWithTitle:(NSString *)title description:(NSString *)description level: (PBNotifyLevel) level;

@end

@implementation PBUserNotify


+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level: (PBNotifyLevel) level {
    [[PBUserNotify defaultNotifier] notifyDelegatesWithTitle:title description:description level:level];    
}

+ (PBUserNotify *) defaultNotifier {
    
    static PBUserNotify *notifier = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        notifier = [[PBUserNotify alloc] init];
    });
    return notifier;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        delegates = [[NSSet set] retain];
    }
    return self;
}

/**
 * Register a delegate to notify. Not thread-safe.
 */
- (void) registerDelegate:(Class <PBNotifyDelegate>)  delegate {
    NSSet * registered = delegates;
    delegates = [[registered setByAddingObject:delegate] retain];
    [registered release];
};

- (void) notifyDelegatesWithTitle:(NSString *)title description:(NSString *)description level:(PBNotifyLevel)level {
    [delegates enumerateObjectsUsingBlock:^(id clazz, BOOL *stop) {
        Class <PBNotifyDelegate> del = clazz;
        [del notifyWithTitle:title description:description level:level];
    }];
}



@end
