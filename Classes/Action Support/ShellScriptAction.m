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

#import "ShellScriptAction.h"
#import "PBUserNotify.h"
#import "PBSandboxAdditions.h"

#define DETAIL_VIEW  @"ShellScriptAction"

#pragma GCC diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wprotocol"


@implementation ShellScriptAction



/**
 * Performs the core 'business' logic of the action using the given parametres
 */
- (NSURL*) handleItemAt: (NSURL *) url forRule: (Rule *) rule withSecurityScope: (NSURL*) sec error: (NSError **) error {

    WithSecurityScopedURL([self securityScope], ^(NSURL* securl){
        
        NSUserUnixTask * task = [[NSUserUnixTask alloc] initWithURL:resource error:error];
        NSFileHandle * stdout = [NSFileHandle fileHandleWithStandardOutput];
        [task setStandardError:stdout];
        [task setStandardOutput:stdout];
        [task executeWithArguments:@[[url absoluteString]] completionHandler:^(NSError *error) {
            if(error) {
                [PBUserNotify notifyWithTitle:@"Error while excuting workflow" description:[error localizedDescription] level:kPBNotifyDebug];
            }
            
        }];
        [task release];
    });    
    return url;

}
/**
 * A description of the action in one word
 */
- (NSString *) userDescription {
    return @"Run shell script";
}



/**
 * An NSView to offer a UI to configure action specific settings
 */
- (NSView *) settingsView {
    if(settingsController == NULL) {
        settingsController = [[ShellScriptActionController alloc]initWithNibName:DETAIL_VIEW bundle:nil];
        [settingsController setRepresentedObject:self];
    }
    return [settingsController view];

    
}


#pragma mark NSCopying

-(id) copyWithZone:(NSZone*) zone {
    ShellScriptAction * other = [[ShellScriptAction alloc] initWithURL:[[self resource]copyWithZone:zone] andSecurityScope:[[self securityScope] copyWithZone:zone]];
    return other;
}


@end
