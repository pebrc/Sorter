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

#import "DeleteAction.h"
#import "PBUserNotify.h"

@implementation DeleteAction

- (NSURL *) handleItemAt: (NSURL *) url forRule: (Rule *) rule withSecurityScope:(NSURL *)sec error:(NSError **)error {
    OSStatus status;
    FSRef target;
    FSRef input;
    status = FSPathMakeRef((const UInt8 *)[[url path]fileSystemRepresentation], &input, false);
    assert(status == 0);
    status = FSMoveObjectToTrashSync(&input, &target, kFSFileOperationDefaultOptions);
    if(status == noErr) {
        [PBUserNotify notifyWithTitle:@"Deleted file" description:[url lastPathComponent] level:kPBNotifyInfo];
        UInt8 * path[512];
        status = FSRefMakePath(&target, (UInt8 *)path, 512);
        if (status == noErr) {
             NSString * newLocation  = [NSString stringWithUTF8String: (const char *)path];
            return [NSURL fileURLWithPath:newLocation];
        }
    }
    return url;
}

- (NSString*)description
{
    return [self userDescription];
}

- (NSString *) userDescription {
    return @"Delete";
}

- (NSString *) userConfigDescription {
    return @"item";
    
}
                                      
- (NSView *) settingsView {
    return nil;
}

- (BOOL) valid {
    return YES;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    
    
}
- (id)initWithCoder:(NSCoder *)decoder {
    return [self init];
}

#pragma mark NSCopying

-(id) copyWithZone:(NSZone *)zone {
    return self;
}
@end
