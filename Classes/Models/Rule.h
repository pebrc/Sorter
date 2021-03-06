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


#import <CoreData/CoreData.h>
#import "Source.h"
#import "Action.h"

#import "PBMetaDataResolver.h"

@interface Rule :  NSManagedObject
{

}

@property (nonatomic, retain) Source * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSPredicate * predicate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSOrderedSet* actions;
@property (readwrite) BOOL active;

@property (nonatomic, readwrite) BOOL flagCreated;
@property (nonatomic, readwrite) BOOL flagRemoved;
@property (nonatomic, readwrite) BOOL flagRenamed;
@property (nonatomic, readwrite) BOOL flagModified;
@property (nonatomic, readwrite) BOOL flagFinderInfoMod;
@property (nonatomic, readwrite) BOOL flagInodeMetaMod;
@property (nonatomic, readwrite) BOOL flagChangeOwner;
@property (nonatomic, readwrite) BOOL flagXattrMod;
@property (nonatomic, readwrite) BOOL flagIsFile;
@property (nonatomic, readwrite) BOOL flagIsDir;
@property (nonatomic, readwrite) BOOL flagIsSymlink;


@end

@interface Rule (CoreDataGeneratedAccessors)
- (void)insertObject:(NSManagedObject *)value inActionsAtIndex:(NSUInteger)idx;

- (void)removeObjectFromActionsAtIndex:(NSUInteger)idx;

- (void)replaceObjectInActionsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;

- (void)insertActions:(NSArray *)value atIndexes:(NSIndexSet *)indexSet;

- (void)removeActionsAtIndexes:(NSIndexSet *)indexSet;

- (void)replaceActionsAtIndexes:(NSIndexSet *)indexSet withActions:(NSArray *)objects;

- (void)addActionsObject:(NSManagedObject *)value;

- (void)removeActionsObject:(NSManagedObject *)value;

- (void)addActions:(NSOrderedSet *)values ;

- (void)removeActions:(NSOrderedSet *)values;
@end



