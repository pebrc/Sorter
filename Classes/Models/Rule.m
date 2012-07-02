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


#import "Rule.h"
#import "TreeSupport.h"



void setFlag(UInt32 flag, BOOL value, Rule* rule) {    
    if(value) {
        [rule setFlags:[NSNumber numberWithUnsignedInt:[[rule flags]unsignedIntValue] |flag]];
    } else {
        [rule setFlags:[NSNumber numberWithUnsignedInt:[[rule flags]unsignedIntValue] & ~flag]];
    }
}

BOOL flag(UInt32 flag, Rule * rule) {
    return ([[rule flags] unsignedIntValue] & flag) ? YES : NO;
}


@implementation Rule 

@dynamic from;
@dynamic to;
@dynamic flags;
@dynamic title;
@dynamic predicate;
@dynamic date;
@dynamic actions;

- (void) awakeFromInsert {
	[super awakeFromInsert];
	[self setDate:[NSDate date]];
	[self setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:
												[NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"kMDItemTextContent = %@", @"Your search goes here"]]]];
}

- (BOOL) flagCreated {
    return flag(kFSEventStreamEventFlagItemCreated, self) ;;
}

- (void) setFlagCreated:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemCreated, flag, self);
}

- (BOOL) flagRemoved {
    return flag(kFSEventStreamEventFlagItemRemoved, self) ;
}

- (void) setFlagRemoved:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemRemoved, flag, self);
}

- (BOOL) flagRenamed {
    return flag(kFSEventStreamEventFlagItemRenamed, self) ;
}

- (void) setFlagRenamed:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemRenamed, flag, self);
}


- (BOOL) flagModified {
    return flag(kFSEventStreamEventFlagItemModified, self) ;
}

- (void) setFlagModified:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemModified, flag, self);
}

- (BOOL) flagFinderInfoMod {
    return flag(kFSEventStreamEventFlagItemFinderInfoMod, self) ;
}

- (void) setFlagFinderInfoMod:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemFinderInfoMod, flag, self);
}


- (BOOL) flagInodeMetaMod {
    return flag(kFSEventStreamEventFlagItemInodeMetaMod, self) ;
}

- (void) setFlagInodeMetaMod:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemInodeMetaMod, flag, self);
}
- (BOOL) flagChangeOwner {
    return flag(kFSEventStreamEventFlagItemChangeOwner, self) ;
}

- (void) setFlagChangeOwner:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemChangeOwner, flag, self);
}

- (BOOL) flagXattrMod {
    return flag(kFSEventStreamEventFlagItemXattrMod, self) ;
}

- (void) setFlagXattrMod:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemXattrMod, flag, self);
}

- (BOOL) flagIsDir {
    return flag(kFSEventStreamEventFlagItemIsDir, self) ;
}

- (void) setFlagIsDir:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemIsDir, flag, self);
}
- (BOOL) flagIsFile {
    return flag(kFSEventStreamEventFlagItemIsFile, self) ;
}

- (void) setFlagIsFile:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemIsFile, flag, self);
}
- (BOOL) flagIsSymlink {
    return flag(kFSEventStreamEventFlagItemIsSymlink, self) ;
}

- (void) setFlagIsSymlink:(BOOL)flag {
    setFlag(kFSEventStreamEventFlagItemIsSymlink, flag, self);
}
@end
