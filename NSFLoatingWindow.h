#import <Cocoa/Cocoa.h>

typedef enum _NSWindowPosition {
    NSPositionLeft          = NSMinXEdge, // 0
    NSPositionRight         = NSMaxXEdge, // 2
    NSPositionTop           = NSMaxYEdge, // 3
    NSPositionBottom        = NSMinYEdge, // 1
    NSPositionLeftTop       = 4,
    NSPositionLeftBottom    = 5,
    NSPositionRightTop      = 6,
    NSPositionRightBottom   = 7,
    NSPositionTopLeft       = 8,
    NSPositionTopRight      = 9,
    NSPositionBottomLeft    = 10,
    NSPositionBottomRight   = 11,
    NSPositionAutomatic     = 12
} NSWindowPosition;

@interface NSFLoatingWindow : NSWindow {
    NSColor *borderColor;
    float borderWidth;
    float viewMargin;
    float arrowBaseWidth;
    float arrowHeight;
    BOOL hasArrow;
    float cornerRadius;
    BOOL drawsRoundCornerBesideArrow;
    
    @private
    NSColor *_NSBackgroundColor;
    __weak NSView *_view;
    __weak NSWindow *_window;
    NSPoint _point;
    NSWindowPosition _side;
    float _distance;
    NSRect _viewFrame;
    BOOL _resizing;
}

- (NSFLoatingWindow *)initWithView:(NSView *)view           // designated initializer
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window 
                            onSide:(NSWindowPosition)side 
                        atDistance:(float)distance;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window 
                        atDistance:(float)distance;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                            onSide:(NSWindowPosition)side 
                        atDistance:(float)distance;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                        atDistance:(float)distance;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                            onSide:(NSWindowPosition)side;
- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point;

// Accessor methods
- (void)setPoint:(NSPoint)point side:(NSWindowPosition)side;
- (NSColor *)borderColor;
- (void)setBorderColor:(NSColor *)value;
- (float)borderWidth;
- (void)setBorderWidth:(float)value;                   // See note 1 below.
- (float)viewMargin;
- (void)setViewMargin:(float)value;                    // See note 2 below.
- (float)arrowBaseWidth;
- (void)setArrowBaseWidth:(float)value;                // See note 2 below.
- (float)arrowHeight;
- (void)setArrowHeight:(float)value;                   // See note 2 below.
- (float)hasArrow;
- (void)setHasArrow:(float)value;
- (float)cornerRadius;
- (void)setCornerRadius:(float)value;                  // See note 2 below.
- (float)drawsRoundCornerBesideArrow;                  // See note 3 below.
- (void)setDrawsRoundCornerBesideArrow:(float)value;   // See note 2 below.
- (void)setBackgroundImage:(NSImage *)value;
- (NSColor *)windowBackgroundColor;                    // See note 4 below.
- (void)setBackgroundColor:(NSColor *)value;
@end
