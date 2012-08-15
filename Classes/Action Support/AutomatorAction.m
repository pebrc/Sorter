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
#import "PBLog.h"
#import "PBGrowlDelegate.h"
#import "Automator/AMWorkflow.h"
#import "PBSandboxAdditions.h"


#define DETAIL_VIEW  @"AutomatorAction"

@implementation AutomatorAction

@synthesize workflow;
@synthesize securityScope;


+ (NSSet *)keyPathsForValuesAffectingValid
{
    return [NSSet setWithObjects:@"workflow", nil];
}


- (id)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"workflow" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    }
    return self;
}

- initWithURL: (NSURL*) url andSecurityScope: (NSData*) sec{
    if (self = [self init]) {
        [self setWorkflow:url];
        [self setSecurityScope:sec];
    }
    return self;
}


- (NSURL*) handleItemAt: (NSURL *) url forRule: (Rule *) rule withSecurityScope:(NSURL *)sec error:(NSError **)error {
    NSURL * secWorkflow = [NSURL URLByResolvingBookmarkData:[self securityScope] options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:nil error:error];
    if(*error) {
        return url;
    }
    __block id result;
    WithSecurityScopedURL([self securityScope], ^(NSURL* securl){
            result = [AMWorkflow runWorkflowAtURL:workflow withInput:[NSArray arrayWithObject:securl] error:error];
    });
    if ([result isKindOfClass:[NSURL class]]) {
        return result;
    }
    return url;
    
}
- (NSString *) userDescription {
    return @"Automate";
}

- (NSString*)description
{
    return [self userDescription];
}

- (NSString *) userConfigDescription {
    if(workflow) {
        return [@"with " stringByAppendingString:[workflow lastPathComponent]];
    }
    return  @"";
}
- (NSView *) settingsView {
    if(settingsController == NULL) {
        settingsController = [[AutomatorActionController alloc]initWithNibName:DETAIL_VIEW bundle:nil];
        [settingsController setRepresentedObject:self];
    }
    return [settingsController view];
}
- (BOOL) valid {
    return workflow != nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"workflow"]) {
        DEBUG_OUTPUT(@"%@", [change description]);
        NSURL * url = [change valueForKey:@"new"];
        if (url) {
            NSError * err = nil;
            NSData * sec = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&err];
            if(err) {
                [PBLog logError:@"%@", [err localizedDescription]];
                return;
            }
            [self setSecurityScope:sec];
        }
    }
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:workflow forKey:@"workflow"];
  [coder encodeObject:securityScope forKey:@"securityScope"];
    
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    NSURL * url = [decoder decodeObjectForKey:@"workflow"];
    NSData * sec = [decoder decodeObjectForKey:@"securityScope"];
    return [self initWithURL:url andSecurityScope:sec];
}



@end
