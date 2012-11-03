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

#import "UserHelp.h"
#define PADDING  15.0
#define MAX_POPOVERWIDTH 175.0

NSString * const HelpDisplayEvent = @"HelpDisplayEvent";
NSString * const HelpPositionedRelativeToRect = @"HelpPositionedRelativeToRect";
NSString * const HelpForView = @"HelpForView";
NSString * const HelpPreferredEdge = @"HelpPreferredEdge";
NSString * const HelpDisplayState = @"HelpDisplayState";

NSString * const HelpText_AddRule = @"HelpText_AddRule";
NSString * const HelpText_SelectDirectory = @"HelpText_SelectDirectory";
NSString * const HelpText_DefineCriteria = @"HelpText_DefineCriteria";
NSString * const HelpText_AddActions = @"HelpText_AddActions";

BOOL hasDisplayedAllHelpItems(NSDictionary* helpItems, NSArray * displayedItems) {
   return  [displayedItems count] == [helpItems count];
}

void storeHelpDisplayInDefaults(NSString* helpKey, NSDictionary* helpItems, NSMutableArray * displayedItems) {
    [displayedItems addObject:helpKey];
    if(hasDisplayedAllHelpItems(helpItems, displayedItems)) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HelpDisplayState];
    }
}

@implementation UserHelp

+(void) displayHelp:(NSString *)helpText For:(NSView *)view showingToThe:(NSRectEdge)side {
    BOOL hasDisplayedHelpAlready = [[NSUserDefaults standardUserDefaults]boolForKey:HelpDisplayState];
    if(hasDisplayedHelpAlready) {
        return;
    }
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:view, HelpForView, [NSNumber numberWithUnsignedInteger:side],HelpPreferredEdge,[view bounds], HelpPositionedRelativeToRect, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HelpDisplayEvent object:helpText userInfo:userInfo];

}

- (id)init {
    self = [super init];
    if (self) {
        displayedHelp = [[NSMutableArray array] retain];
        helpDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
                          @"Start by adding a rule", HelpText_AddRule,
                          @"Select the base directory to watch.", HelpText_SelectDirectory,
                          @"Define criteria for files your are interested in.", HelpText_DefineCriteria,
                          @"Finally define actions to be executed if an event matching the criteria you defined occurs.", HelpText_AddActions, nil] retain];
    }
    return  self;
}

- (void) dealloc {
    [displayedHelp release];
    [helpDictionary release];
    [super dealloc];
}

-(void) displayHelpContents:(NSNotification *)note {

    NSString * helpKey = [note object];
    storeHelpDisplayInDefaults(helpKey, helpDictionary, displayedHelp);
    NSString * helpText = [helpDictionary objectForKey:helpKey];
    if(!helpText) {
        return;
    }
    /**Extract help parameters from notification **/
    NSDictionary * positioningInfo = [note userInfo];
    NSRect bounds = [[positioningInfo valueForKey:HelpPositionedRelativeToRect] rectValue];
    NSView * view = [positioningInfo valueForKey:HelpForView];
    NSRectEdge preferredEdge = [[positioningInfo valueForKey:HelpPreferredEdge] unsignedIntegerValue];
    /** store style attributes with help text **/
    NSAttributedString * attributedHelpText = [[NSAttributedString alloc] initWithString:helpText attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]],
                                                          NSForegroundColorAttributeName: [NSColor whiteColor]}];
    
    /** Bounds calculation as proposed by  Michael Robinson <mike@pagesofinterest.net>**/
    NSRect viewRect =[attributedHelpText boundingRectWithSize:NSMakeSize(MAX_POPOVERWIDTH, 0) options:NSStringDrawingUsesLineFragmentOrigin];
    viewRect.size.width = viewRect.size.width *= (25/(viewRect.size.width+2)+1);
    
    NSSize size = viewRect.size;
    NSSize popoverSize = NSMakeSize(viewRect.size.width + (PADDING * 2), viewRect.size.height + (PADDING * 2));
    
    viewRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);
    
    NSTextField *label = [[[NSTextField alloc] initWithFrame:NSMakeRect(PADDING, PADDING, size.width, size.height)] retain];
    
    
    [label setBezeled:NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    [label setSelectable:NO];
    [label setAttributedStringValue:attributedHelpText];
    [[label cell] setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSView *helpView = [[[NSView alloc] initWithFrame:viewRect] retain];
    [helpView addSubview:label];
    [label setBounds:NSMakeRect(PADDING, PADDING, size.width, size.height)];
    [helpView awakeFromNib];
    
    NSViewController *controller = [[[NSViewController alloc] init] retain];
    [controller setView:helpView];
    
    NSPopover *popover = [[[NSPopover alloc] init] retain];
    [popover setContentSize:popoverSize];
    [popover setContentViewController:controller];
    [popover setAppearance:NSPopoverAppearanceHUD];
    [popover setAnimates:YES];
    [popover setBehavior:NSPopoverBehaviorTransient];
    [popover showRelativeToRect:bounds
                         ofView:view
                  preferredEdge:preferredEdge];
    
    [popover release];
    [controller release];
    [helpView release];
    [label release];
}

@end
