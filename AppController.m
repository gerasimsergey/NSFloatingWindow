#import "AppController.h"


@implementation AppController


- (void)awakeFromNib
{
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}


- (IBAction)changeSide:(id)sender
{
    NSDisableScreenUpdates();
    if (attachedWindow) {
        [self toggleWindow:sender];
    }
    [self toggleWindow:sender];
    NSEnableScreenUpdates();
}


- (IBAction)changeBorderColor:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setBorderColor:[sender color]];
        [textField setTextColor:[sender color]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeBackgroundColor:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setBackgroundColor:[sender color]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeViewMargin:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setViewMargin:[sender floatValue]];
        [attachedWindow setBorderWidth:[borderWidthSlider floatValue]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeBorderWidth:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setBorderWidth:[sender floatValue]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeCornerRadius:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setCornerRadius:[sender floatValue]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeHasArrow:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setHasArrow:([sender state] == NSOnState)];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeDrawsRoundCornerBesideArrow:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setDrawsRoundCornerBesideArrow:([sender state] == NSOnState)];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeArrowBaseWidth:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setArrowBaseWidth:[sender floatValue]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeArrowHeight:(id)sender
{
    if (attachedWindow) {
        [attachedWindow setArrowHeight:[sender floatValue]];
    } else {
        [self toggleWindow:sender];
    }
}


- (IBAction)changeDistance:(id)sender
{
    NSDisableScreenUpdates();
    if (attachedWindow) {
        [self toggleWindow:sender];
    }
    [self toggleWindow:sender];
    NSEnableScreenUpdates();
}


- (IBAction)toggleWindow:(id)sender
{
    if (!attachedWindow) {
        int side = [sidePopup indexOfSelectedItem];
        NSPoint buttonPoint = NSMakePoint(NSMidX([toggleButton frame]),
                                          NSMidY([toggleButton frame]));
        attachedWindow = [[NSFLoatingWindow alloc] initWithView:view 
                                                attachedToPoint:buttonPoint 
                                                       inWindow:[toggleButton window] 
                                                         onSide:side 
                                                     atDistance:[distanceSlider floatValue]];
        [attachedWindow setBorderColor:[borderColorWell color]];
        [textField setTextColor:[borderColorWell color]];
        [attachedWindow setBackgroundColor:[backgroundColorWell color]];
        [attachedWindow setViewMargin:[viewMarginSlider floatValue]];
        [attachedWindow setBorderWidth:[borderWidthSlider floatValue]];
        [attachedWindow setCornerRadius:[cornerRadiusSlider floatValue]];
        [attachedWindow setHasArrow:([hasArrowCheckbox state] == NSOnState)];
        [attachedWindow setDrawsRoundCornerBesideArrow:
            ([drawRoundCornerBesideArrowCheckbox state] == NSOnState)];
        [attachedWindow setArrowBaseWidth:[arrowBaseWidthSlider floatValue]];
        [attachedWindow setArrowHeight:[arrowHeightSlider floatValue]];
        
        [[toggleButton window] addChildWindow:attachedWindow ordered:NSWindowAbove];
    } else {
        [[toggleButton window] removeChildWindow:attachedWindow];
        [attachedWindow orderOut:self];
        [attachedWindow release];
        attachedWindow = nil;
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
    return YES;
}


@end
