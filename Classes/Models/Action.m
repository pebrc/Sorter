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

#import "Action.h"
#import "Rule.h"
#import <objc/runtime.h>

@interface Action(PrivateAPI)
    -(void) registerObserver:(id) obj AndStopObserving: (id)old;

@end
@implementation Action

@dynamic order;
@dynamic strategy;
@dynamic rule;

+ (NSSet *) availableActions {
    Class *buffer = NULL;
    int count, size;
    do {
        count = objc_getClassList(NULL, 0);
        buffer = realloc(buffer, count * sizeof(*buffer));
        NSAssert(buffer != NULL, @"realloc failed");
        size = objc_getClassList(buffer, count);
    } while (size != count);
    
    NSMutableSet * result = [NSMutableSet set];
    for (int i = 0; i < count; i++) {
        Class candidate = buffer[i];
        if(class_conformsToProtocol(candidate, @protocol(ActionStrategy))) {
            [result addObject:buffer[i]];
        }
    }
    free(buffer);
    return result;
}

+ (NSSet *)keyPathsForValuesAffectingValid
{
    return [NSSet setWithObjects:@"strategy", nil];
}



- (NSView *) settingsView {
    id<ActionStrategy> s = [self strategy];
    if(s != NULL) {
        NSView * v = [s settingsView];
        return v;
    }
    return NULL;
}

- (NSString *) userDescription {
    return [[self strategy] userDescription];
}

- (NSString *) userConfigDescription {
    return [[self strategy] userConfigDescription];
}

- (BOOL) handleItemAt: (NSURL *) url error: (NSError **)err{
    return [[self strategy] handleItemAt:url forRule:[self rule] error:err];
}

-(BOOL) valid {
    return [[self strategy] valid];
}

-(void) setStrategy:(id<ActionStrategy>)strategy {

    id old = [self primitiveValueForKey:@"strategy"];
    if (strategy != old) {
        [self registerObserver: strategy AndStopObserving: old];
    }
    [self willChangeValueForKey:@"strategy"];
    [self setPrimitiveValue:strategy forKey:@"strategy"];
    [self didChangeValueForKey:@"strategy"];
    
}

- (void) registerObserver:(id)obj AndStopObserving:(id)old{
    if(old) {
        [old removeObserver:self forKeyPath:@"valid"];
    }
    if(obj) {
        [obj addObserver:self 
              forKeyPath:@"valid" 
                 options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                 context:NULL];
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"valid"]) {
        [self willChangeValueForKey:@"valid"];
        [self didChangeValueForKey:@"valid"];
    }
    
}

@end
