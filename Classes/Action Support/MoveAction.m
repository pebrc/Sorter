//Copyright (c) 2011 Peter Brachwitz
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

#import "MoveAction.h"
#define DETAIL_VIEW  @"MoveAction"
@interface MoveAction(PrivateApi)
- (NSURL*) targetURLFor: (NSURL *) file;
@end


@implementation MoveAction
@synthesize userDescription;
@synthesize target;

- (id)init
{
    self = [super init];
    if (self) {
        userDescription = @"Move";
    }
    
    return self;
}

- initWithURL: (NSString*) url {
    if (self = [self init]) {
        [self setTarget:url];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [settingsController release];
    [userDescription release];
}

- (NSString*) userConfigDescription {
    if(target) {
        return [@"to " stringByAppendingString:target];
    }
    return  @"";
}

- (BOOL) handleItemAt: (NSURL *) url forRule: (Rule *) rule error: (NSError **) error {
    #if NO_IO
    BOOL success = YES;
    DEBUG_OUTPUT(@"moving item at %@ to %@", url, [self targetURLFor:url]);
    #else
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL success = [manager moveItemAtURL:url toURL:[self targetURLFor:url]  error:error];
    #endif
    return success;
}

-(void) setTarget:(NSString *)atarget{
    if(target == atarget) {
        return;
    }
    [self willChangeValueForKey:@"valid"];
    [self willChangeValueForKey:@"target"];
    [target release];
    target = [atarget retain];
    [self didChangeValueForKey:@"target"];
    [self didChangeValueForKey:@"valid"];
}

- (NSURL *) targetURLFor:(NSURL *)file {
	if (file != nil) {
		NSURL *dir = [NSURL URLWithString:[self target]];
		return [dir URLByAppendingPathComponent:[file lastPathComponent]];
	}
	return nil;	
}

/**
 * Violating MVC here. But cant think of an easy way to make this work without a lot of 
 * extra infrastructure. TODO: Think about a cleaner way of doing this: convention: try to find a matching view by naming conventions?? seperate strategies for model and view?
 */
- (NSView *) settingsView {
    if(settingsController == NULL) {
        settingsController = [[MoveActionController alloc]initWithNibName:DETAIL_VIEW bundle:nil];
        [settingsController setRepresentedObject:self];
    }
    return [settingsController view];

}

-(BOOL) valid {
    return target != nil;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:target forKey:@"target"];
    
}
- (id)initWithCoder:(NSCoder *)decoder {

    NSString * url = [decoder decodeObjectForKey:@"target"];    
    return [self initWithURL:url];
}



@end
