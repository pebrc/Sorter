//Copyright (c) 2012 Peter Brachwitz
//
//Derived from Apple Sample Code
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


#import "ImageAndTextCell.h"

#define kIconImageSize		16.0
#define kStatusIconSize     10.0

#define kImageOriginXOffset 3
#define kImageOriginYOffset 1

#define kTextOriginXOffset	2
#define kTextOriginYOffset	2
#define kTextHeightAdjust	4


NSRect resizeCellFrameWithBlock(NSRect cellFrame, NSSize imageSize, CGFloat yOriginOffset, void (^draw)(NSRect imageFrame)) {
    NSRect imageFrame;
    
    NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
    
    imageFrame.origin.x += kImageOriginXOffset;
    imageFrame.size = imageSize;
    
    CGFloat yOffset = floor(((NSHeight(cellFrame) - imageSize.height) - yOriginOffset) / 2.0);
    imageFrame.origin.y += yOffset;

    
    draw(imageFrame);
    
    NSRect newFrame = cellFrame;
    newFrame.origin.x += kTextOriginXOffset;
    newFrame.origin.y += kTextOriginYOffset;
    newFrame.size.height -= kTextHeightAdjust;
    return newFrame;


}



NSRect drawImageWithOffsetAndReturnRemainingRect(NSRect cellFrame, NSImage * image, CGFloat yOriginOffset, NSSize imageSize) {
    
    return resizeCellFrameWithBlock(cellFrame, imageSize, yOriginOffset, ^(NSRect imageFrame){
        [image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    });
    
}

NSRect drawImageAndReturnRemainingRect(NSRect cellFrame, NSImage * image, NSSize imageSize) {
    
    return drawImageWithOffsetAndReturnRemainingRect(cellFrame, image, kImageOriginYOffset, imageSize);
    
}




@implementation ImageAndTextCell

@synthesize image, active;



- (id)init
{
    self = [super init];
    if (self) {
        [self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        statusIcon = [[NSImage imageNamed:@"StatusActive"] retain];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [image release];
    [statusIcon release];
    image = nil;
    statusIcon = nil;
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	copyWithZone:zone
// -------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone*)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell*)[super copyWithZone:zone];
    cell->image = [image retain];
    cell->statusIcon = [statusIcon retain];
    return cell;
}

// -------------------------------------------------------------------------------
//	setImage:anImage
// -------------------------------------------------------------------------------
- (void)setImage:(NSImage*)anImage
{
    if (anImage != image)
	{
        [image release];
        image = [anImage retain];
		[image setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
    }
}


// -------------------------------------------------------------------------------
//	isGroupCell:
// -------------------------------------------------------------------------------
- (BOOL)isGroupCell
{
    return ([self image] == nil && [[self title] length] > 0);
}

// -------------------------------------------------------------------------------
//	titleRectForBounds:cellRect
//
//	Returns the proper bound for the cell's title while being edited
// -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
{
    return resizeCellFrameWithBlock(cellRect, [image size], kImageOriginYOffset,^(NSRect imageRect){});
    
}

// -------------------------------------------------------------------------------
//	editWithFrame:inView:editor:delegate:event
// -------------------------------------------------------------------------------
- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

// -------------------------------------------------------------------------------
//	selectWithFrame:inView:editor:delegate:event:start:length
// -------------------------------------------------------------------------------
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

// -------------------------------------------------------------------------------
//	drawWithFrame:cellFrame:controlView:
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	if (image != nil)
	{    
        NSRect newFrame = drawImageAndReturnRemainingRect(cellFrame, image, [image size]);
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ([self isGroupCell])
		{
            
            if([self active]) {
                NSRect newFrame = drawImageWithOffsetAndReturnRemainingRect(cellFrame, statusIcon,0.0, NSMakeSize(kStatusIconSize, kStatusIconSize));
                [super drawWithFrame:newFrame inView:controlView];

                
            } else {
                NSRect newFrame = resizeCellFrameWithBlock(cellFrame, NSMakeSize(kStatusIconSize, kStatusIconSize), kImageOriginYOffset, ^(NSRect imageFrame){});
                [super drawWithFrame:newFrame inView:controlView];
            }
                
            
		}
	}
}

// -------------------------------------------------------------------------------
//	cellSize:
// -------------------------------------------------------------------------------
- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

// -------------------------------------------------------------------------------
//	hitTestForEvent:
//
//	In 10.5, we need you to implement this method for blocking drag and drop of a given cell.
//	So NSCell hit testing will determine if a row can be dragged or not.
//
//	NSTableView calls this cell method when starting a drag, if the hit cell returns
//	NSCellHitTrackableArea, the particular row will be tracked instead of dragged.
//
// -------------------------------------------------------------------------------
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	NSInteger result = NSCellHitTrackableArea;    
	return result;
}

@end

