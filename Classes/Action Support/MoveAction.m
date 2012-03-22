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
#define YEAR @"$YYYY"
#define MONTH @"$MM"
#define DAY @"$DD"

@interface MoveAction(PrivateApi)
- (NSURL*) targetURLFor: (NSURL *) file within: (NSURL*) dir;
- (NSURL*) targetDirFor: (NSURL *) file;
- (NSString*) expandPlaceholders: (NSString*) stringWithPlaceholders;
- (NSDictionary *) variableDictionary;
@end


@implementation MoveAction
@synthesize userDescription;
@synthesize target;

+ (NSSet *)keyPathsForValuesAffectingValid
{
    return [NSSet setWithObjects:@"target", nil];
}

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

- (NSURL *) handleItemAt: (NSURL *) url forRule: (Rule *) rule error: (NSError **) error {
    NSURL * dir = [self targetDirFor:url];
    NSURL * t = [self targetURLFor:url within: dir];
    #if NO_IO
    BOOL success = YES;
    DEBUG_OUTPUT(@"moving item at %@ to %@", url, target);
    #else
    NSFileManager * manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:[dir path]]) {
        [manager createDirectoryAtPath:[dir path] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL success = [manager moveItemAtURL:url toURL:t  error:error];
    #endif
    if (success) {
        return t;
    }
    return url;
}



- (NSURL *) targetURLFor:(NSURL *)file within: (NSURL*) dir {
	if (dir != nil) {
		return [dir URLByAppendingPathComponent:[file lastPathComponent]];
	}
	return nil;	
}

- (NSURL *) targetDirFor:(NSURL *)file {
    if(file != nil) {
        NSString * expandedString = [self expandPlaceholders: [self target]];
		return  [NSURL URLWithString:expandedString];

    }
    return nil;
}


- (NSString*) expandPlaceholders:(NSString *)stringWithPlaceholders {
    NSDictionary * dict = [self variableDictionary];
    NSMutableString * result =  [NSMutableString stringWithString:stringWithPlaceholders];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [result replaceOccurrencesOfString:key 
                                withString:obj 
                                   options:NSCaseInsensitiveSearch 
                                     range:NSMakeRange(0, [result length])];
    }];    
    return result ;    
}

- (NSDictionary *) variableDictionary {
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    return [NSDictionary dictionaryWithObjectsAndKeys:  [NSString stringWithFormat:@"%u",[comps year]],YEAR,
            [NSString stringWithFormat:@"%02u", [comps month]], MONTH,  
            [NSString stringWithFormat:@"%02u", [comps day]], DAY, 
            nil];
}


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
