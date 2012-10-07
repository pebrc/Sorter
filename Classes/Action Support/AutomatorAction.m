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

#import "AutomatorAction.h"
#import "PBUserNotify.h"
#import "PBSandboxAdditions.h"

#pragma GCC diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wprotocol"

#define DETAIL_VIEW  @"AutomatorAction"

@implementation AutomatorAction




- (NSURL*) handleItemAt: (NSURL *) url forRule: (Rule *) rule withSecurityScope:(NSURL *)sec error:(NSError **)error {
    __block id resultingUrl = url;
    WithSecurityScopedURL([self securityScope], ^(NSURL* securl){

        NSUserAutomatorTask * task = [[NSUserAutomatorTask alloc] initWithURL:resource error:error];
        [task executeWithInput:securl completionHandler:^(id result, NSError *error) {
            if(error) {
                [PBUserNotify notifyWithTitle:@"Error while excuting workflow" description:[error localizedDescription] level:kPBNotifyDebug];
                return;
            }
            if([result isKindOfClass: [NSURL class]]) {
                resultingUrl = result;
            }
            
        }];
        [task release];
    });
    return resultingUrl;
    
}
- (NSString *) userDescription {
    return @"Automate";
}

- (NSString*)description
{
    return [self userDescription];
}

- (NSView *) settingsView {
    if(settingsController == NULL) {
        settingsController = [[AutomatorActionController alloc]initWithNibName:DETAIL_VIEW bundle:nil];
        [settingsController setRepresentedObject:self];
    }
    return [settingsController view];
}




@end
