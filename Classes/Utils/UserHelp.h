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
//
//
//Custom popover inspired by Michael Robinson <mike@pagesofinterest.net>

#import <Foundation/Foundation.h>
NSString * const HelpDisplayEvent;
NSString * const HelpPositionedRelativeToRect;
NSString * const HelpForView;
NSString * const HelpPreferredEdge;
NSString * const HelpDisplayState;

NSString * const HelpText_AddRule;
NSString * const HelpText_SelectDirectory;
NSString * const HelpText_DefineCriteria;
NSString * const HelpText_AddActions;

@interface UserHelp : NSObject {
    NSDictionary*  helpDictionary;
    NSMutableArray* displayedHelp;
}

+(void) displayHelp:(NSString *)helpText For:(NSView *)view showingToThe:(NSRectEdge)side;

-(void) displayHelpContents:(NSNotification *)note;

@end
