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

#import "AbstractActionWithSecurityScopedResource.h"
#import "PBUserNotify.h"
#import "PBSandboxAdditions.h"

@interface AbstractActionWithSecurityScopedResource(PrivateAPI)
- (void) updateSecurityScopeFor: (NSURL*) url;
@end


@implementation AbstractActionWithSecurityScopedResource

@synthesize resource;
@synthesize securityScope;


+ (NSSet *)keyPathsForValuesAffectingValid
{
    return [NSSet setWithObjects:@"resource", nil];
}


- (id)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"resource" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        
    }
    return self;
}

- initWithURL: (NSURL*) url andSecurityScope: (NSData*) sec{
    if (self = [self init]) {
        [self setSecurityScope:sec];//set resource first to avoid unnecessary and failing bookmarking attempts
        [self setResource:url];

    }
    return self;
}


- (NSURL*) handleItemAt: (NSURL *) url forRule: (Rule *) rule withSecurityScope:(NSURL *)sec error:(NSError **)error {
    [NSException raise:@"Abstract class" format:@"Do not instantiate directly"] ;
    return nil;
}
- (NSString *) userDescription {
    [NSException raise:@"Abstract class" format:@"Do not instantiate directly"] ;
    return nil;
}

- (NSString*)description
{
    return [self userDescription];
}

- (NSString *) userConfigDescription {
    if(resource) {
        return [@"using " stringByAppendingString:[resource lastPathComponent]];
    }
    return  @"";
}
- (NSView *) settingsView {
    [NSException raise:@"Abstract class" format:@"Do not instantiate directly"] ;
    return nil;
}
- (BOOL) valid {
    return resource != nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"resource"]) {
        DEBUG_OUTPUT(@"Action with resource changed: %@", [change description]);
        NSURL * url = [change valueForKey:@"new"];
        if ([url isKindOfClass:[NSURL class]]) {
            [self updateSecurityScopeFor:url];
        }
    }
}

- (void) updateSecurityScopeFor:(NSURL *)url {
    NSURL * currentTarget = [NSURL URLByResolvingBookmarkData:securityScope options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:nil error:nil];
    //can be considered as already processed if paths are same -- bit of a shortcut 
    if(currentTarget != nil && [[url path]isEqual:[currentTarget path]]) {
        return;
    }
    NSError * err = nil;
    NSData * sec = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&err];
    if(err) {
        [PBUserNotify notifyWithTitle:@"No bookmarkable security scope" description:[err localizedDescription] level:kPBNotifyDebug];
        return;
    }
    [self setSecurityScope:sec];

}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:resource forKey:@"resource"];
    [coder encodeObject:securityScope forKey:@"securityScope"];
    
}
- (id)initWithCoder:(NSCoder *)decoder {

    NSData * sec = [decoder decodeObjectForKey:@"securityScope"];
    NSURL * url = [decoder decodeObjectForKey:@"resource"];
    return [self initWithURL:url andSecurityScope:sec];
}


@end
