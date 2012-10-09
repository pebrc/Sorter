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

#import "TableViewDelegateWithDragSupport.h"

@implementation TableViewDelegateWithDragSupport 

@synthesize tableView;
@synthesize arrayController;
    
- (void)awakeFromNib {
        [super awakeFromNib];        
        [tableView registerForDraggedTypes:[NSArray arrayWithObjects:[self.arrayController entityName], nil]];
        [tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}
    

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pasteboard {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pasteboard declareTypes:[NSArray arrayWithObject:[self.arrayController entityName]] owner:self];
        [pasteboard setData:data forType:[self.arrayController entityName]];
        return YES;
}
    
- (NSDragOperation)tableView:(NSTableView*)targetView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
	if ([info draggingSource] != tableView) {
        return NSDragOperationNone;
    }
    if (op == NSTableViewDropOn) {
        [targetView setDropRow:row dropOperation:NSTableViewDropAbove];
    }
	return NSDragOperationMove;
}
    
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	
	NSDictionary *bindingInfo = [self.arrayController infoForBinding:@"contentArray"];
	NSMutableOrderedSet *s = [[bindingInfo objectForKey:NSObservedObjectKey] mutableOrderedSetValueForKeyPath:[bindingInfo objectForKey:NSObservedKeyPathKey]];
	
	NSPasteboard *pasteboard = [info draggingPasteboard];
	NSData *rowData = [pasteboard dataForType:[self.arrayController entityName]];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	if ([rowIndexes firstIndex] > row) {
		[s moveObjectsAtIndexes:rowIndexes toIndex:row];
	} else {
		[s moveObjectsAtIndexes:rowIndexes toIndex:row-[rowIndexes count]];
	}
	
	return YES;
}


@end
