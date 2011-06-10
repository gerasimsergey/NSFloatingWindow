#import <Cocoa/Cocoa.h>
#import "NSFLoatingWindow.h"

@interface AppController : NSObject {
    
    IBOutlet NSPopUpButton *sidePopup;
    IBOutlet NSColorWell *borderColorWell;
    IBOutlet NSColorWell *backgroundColorWell;
    IBOutlet NSSlider *viewMarginSlider;
    IBOutlet NSSlider *borderWidthSlider;
    IBOutlet NSSlider *cornerRadiusSlider;
    IBOutlet NSButton *hasArrowCheckbox;
    IBOutlet NSButton *drawRoundCornerBesideArrowCheckbox;
    IBOutlet NSSlider *arrowBaseWidthSlider;
    IBOutlet NSSlider *arrowHeightSlider;
    IBOutlet NSSlider *distanceSlider;
    IBOutlet NSButton *toggleButton;
    
    IBOutlet NSTextField *textField;
    IBOutlet NSView *view;
    NSFLoatingWindow *attachedWindow;
}

- (IBAction)changeSide:(id)sender;
- (IBAction)changeBorderColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)changeViewMargin:(id)sender;
- (IBAction)changeBorderWidth:(id)sender;
- (IBAction)changeCornerRadius:(id)sender;
- (IBAction)changeHasArrow:(id)sender;
- (IBAction)changeDrawsRoundCornerBesideArrow:(id)sender;
- (IBAction)changeArrowBaseWidth:(id)sender;
- (IBAction)changeArrowHeight:(id)sender;
- (IBAction)changeDistance:(id)sender;
- (IBAction)toggleWindow:(id)sender;

@end
