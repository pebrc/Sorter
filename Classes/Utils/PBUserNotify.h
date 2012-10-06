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


#import <Foundation/Foundation.h>

typedef enum {
    kPBNotifyFatal = 1,
    kPBNotifyError = 2,
    kPBNotifyWarn = 3,
    kPBNotifyInfo = 4,
    kPBNotifyDebug = 5,
    kPBNotifyTrace = 6
}PBNotifyLevel;

@protocol PBNotifyDelegate <NSObject>

+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level:(PBNotifyLevel)level;

@end

@interface PBUserNotify : NSObject {
    @private
    NSSet * delegates;
}

+ (void) notifyWithTitle:(NSString *)title description:(NSString *)description level: (PBNotifyLevel) level;

+ (PBUserNotify *) defaultNotifier;

- (void) registerDelegate:(Class <PBNotifyDelegate>)  delegate;

@end
