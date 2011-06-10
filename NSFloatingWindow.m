#import "NSFLoatingWindow.h"

#define NSFLoatingWindow_DEFAULT_BACKGROUND_COLOR [NSColor colorWithCalibratedWhite:0.1 alpha:0.75]
#define NSFLoatingWindow_DEFAULT_BORDER_COLOR [NSColor whiteColor]
#define NSFLoatingWindow_SCALE_FACTOR [[NSScreen mainScreen] userSpaceScaleFactor]

@interface NSFLoatingWindow (NSPrivateMethods)

// Geometry
- (void)_updateGeometry;
- (NSWindowPosition)_bestSideForAutomaticPosition;
- (float)_arrowInset;

// Drawing
- (void)_updateBackground;
- (NSColor *)_backgroundColorPatternImage;
- (NSBezierPath *)_backgroundPath;
- (void)_appendArrowToPath:(NSBezierPath *)path;
- (void)_redisplay;

@end

@implementation NSFLoatingWindow


#pragma mark Initializers


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window 
                            onSide:(NSWindowPosition)side 
                        atDistance:(float)distance
{
    // Insist on having a valid view.
    if (!view) {
        return nil;
    }
    
    // Create dummy initial contentRect for window.
    NSRect contentRect = NSZeroRect;
    contentRect.size = [view frame].size;
    
    if ((self = [super initWithContentRect:contentRect 
                                 styleMask:NSBorderlessWindowMask 
                                   backing:NSBackingStoreBuffered 
                                     defer:NO])) {
        _view = view;
        _window = window;
        _point = point;
        _side = side;
        _distance = distance;
        
        
        [super setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:NO];
        [self setExcludedFromWindowsMenu:YES];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self useOptimizedDrawing:YES];
        
        
        _NSBackgroundColor = [NSFLoatingWindow_DEFAULT_BACKGROUND_COLOR copy];
        borderColor = [NSFLoatingWindow_DEFAULT_BORDER_COLOR copy];
        borderWidth = 2.0;
        viewMargin = 2.0;
        arrowBaseWidth = 20.0;
        arrowHeight = 16.0;
        hasArrow = YES;
        cornerRadius = 8.0;
        drawsRoundCornerBesideArrow = YES;
        _resizing = NO;
        
        
        if (_side == NSPositionAutomatic) {
            _side = [self _bestSideForAutomaticPosition];
        }
        
        
        [self _updateGeometry];
        
        
        [self _updateBackground];
        
        
        [[self contentView] addSubview:_view];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(windowDidResize:) 
                                                     name:NSWindowDidResizeNotification 
                                                   object:self];
    }
    return self;
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window 
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:window onSide:NSPositionAutomatic 
                   atDistance:distance];
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                            onSide:(NSWindowPosition)side 
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:nil onSide:side 
                   atDistance:distance];
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                        atDistance:(float)distance
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:nil onSide:NSPositionAutomatic 
                   atDistance:distance];
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                          inWindow:(NSWindow *)window
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:window onSide:NSPositionAutomatic 
                   atDistance:0];
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point 
                            onSide:(NSWindowPosition)side
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:nil onSide:side 
                   atDistance:0];
}


- (NSFLoatingWindow *)initWithView:(NSView *)view 
                   attachedToPoint:(NSPoint)point
{
    return [self initWithView:view attachedToPoint:point 
                     inWindow:nil onSide:NSPositionAutomatic 
                   atDistance:0];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [borderColor release];
    [_NSBackgroundColor release];
    
    [super dealloc];
}


#pragma mark Geometry


- (void)_updateGeometry
{
    NSRect contentRect = NSZeroRect;
    contentRect.size = [_view frame].size;
    
    // Account for viewMargin.
    _viewFrame = NSMakeRect(viewMargin * NSFLoatingWindow_SCALE_FACTOR,
                            viewMargin * NSFLoatingWindow_SCALE_FACTOR,
                            [_view frame].size.width, [_view frame].size.height);
    contentRect = NSInsetRect(contentRect, 
                              -viewMargin * NSFLoatingWindow_SCALE_FACTOR, 
                              -viewMargin * NSFLoatingWindow_SCALE_FACTOR);
    
    float scaledArrowHeight = arrowHeight * NSFLoatingWindow_SCALE_FACTOR;
    switch (_side) {
        case NSPositionLeft:
        case NSPositionLeftTop:
        case NSPositionLeftBottom:
            contentRect.size.width += scaledArrowHeight;
            break;
        case NSPositionRight:
        case NSPositionRightTop:
        case NSPositionRightBottom:
            _viewFrame.origin.x += scaledArrowHeight;
            contentRect.size.width += scaledArrowHeight;
            break;
        case NSPositionTop:
        case NSPositionTopLeft:
        case NSPositionTopRight:
            _viewFrame.origin.y += scaledArrowHeight;
            contentRect.size.height += scaledArrowHeight;
            break;
        case NSPositionBottom:
        case NSPositionBottomLeft:
        case NSPositionBottomRight:
            contentRect.size.height += scaledArrowHeight;
            break;
        default:
            break; 
    }
    
    
    contentRect.origin = (_window) ? [_window convertBaseToScreen:_point] : _point;
    float arrowInset = [self _arrowInset];
    float halfWidth = contentRect.size.width / 2.0;
    float halfHeight = contentRect.size.height / 2.0;
    switch (_side) {
        case NSPositionTopLeft:
            contentRect.origin.x -= contentRect.size.width - arrowInset;
            break;
        case NSPositionTop:
            contentRect.origin.x -= halfWidth;
            break;
        case NSPositionTopRight:
            contentRect.origin.x -= arrowInset;
            break;
        case NSPositionBottomLeft:
            contentRect.origin.y -= contentRect.size.height;
            contentRect.origin.x -= contentRect.size.width - arrowInset;
            break;
        case NSPositionBottom:
            contentRect.origin.y -= contentRect.size.height;
            contentRect.origin.x -= halfWidth;
            break;
        case NSPositionBottomRight:
            contentRect.origin.x -= arrowInset;
            contentRect.origin.y -= contentRect.size.height;
            break;
        case NSPositionLeftTop:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= arrowInset;
            break;
        case NSPositionLeft:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= halfHeight;
            break;
        case NSPositionLeftBottom:
            contentRect.origin.x -= contentRect.size.width;
            contentRect.origin.y -= contentRect.size.height - arrowInset;
            break;
        case NSPositionRightTop:
            contentRect.origin.y -= arrowInset;
            break;
        case NSPositionRight:
            contentRect.origin.y -= halfHeight;
            break;
        case NSPositionRightBottom:
            contentRect.origin.y -= contentRect.size.height - arrowInset;
            break;
        default:
            break; 
    }
    
    
    switch (_side) {
        case NSPositionLeft:
        case NSPositionLeftTop:
        case NSPositionLeftBottom:
            contentRect.origin.x -= _distance;
            break;
        case NSPositionRight:
        case NSPositionRightTop:
        case NSPositionRightBottom:
            contentRect.origin.x += _distance;
            break;
        case NSPositionTop:
        case NSPositionTopLeft:
        case NSPositionTopRight:
            contentRect.origin.y += _distance;
            break;
        case NSPositionBottom:
        case NSPositionBottomLeft:
        case NSPositionBottomRight:
            contentRect.origin.y -= _distance;
            break;
        default:
            break; 
    }
    
    
    [self setFrame:contentRect display:NO];
    [_view setFrame:_viewFrame];
}


- (NSWindowPosition)_bestSideForAutomaticPosition
{
    
    NSRect screenFrame;
    if (_window && [_window screen]) {
        screenFrame = [[_window screen] visibleFrame];
    } else {
        screenFrame = [[NSScreen mainScreen] visibleFrame];
    }
    NSPoint pointOnScreen = (_window) ? [_window convertBaseToScreen:_point] : _point;
    NSSize viewSize = [_view frame].size;
    viewSize.width += (viewMargin * NSFLoatingWindow_SCALE_FACTOR) * 2.0;
    viewSize.height += (viewMargin * NSFLoatingWindow_SCALE_FACTOR) * 2.0;
    NSWindowPosition side = NSPositionBottom; 
    float scaledArrowHeight = (arrowHeight * NSFLoatingWindow_SCALE_FACTOR) + _distance;
    
    if (pointOnScreen.y - viewSize.height - scaledArrowHeight < NSMinY(screenFrame)) {
        
        if (pointOnScreen.x + viewSize.width + scaledArrowHeight >= NSMaxX(screenFrame)) {
            
            if (pointOnScreen.x - viewSize.width - scaledArrowHeight < NSMinX(screenFrame)) {
                
                if (pointOnScreen.y + viewSize.height + scaledArrowHeight < NSMaxY(screenFrame)) {
                    side = NSPositionTop;
                }
            } else {
                side = NSPositionLeft;
            }
        } else {
            side = NSPositionRight;
        }
    }
    
    float halfWidth = viewSize.width / 2.0;
    float halfHeight = viewSize.height / 2.0;
    
    NSRect parentFrame = (_window) ? [_window frame] : screenFrame;
    float arrowInset = [self _arrowInset];
    
    switch (side) {
        case NSPositionBottom:
        case NSPositionTop:
            
            if (pointOnScreen.x - halfWidth < NSMinX(parentFrame)) {
                
                if (pointOnScreen.x + viewSize.width - arrowInset < NSMaxX(screenFrame)) {
                    
                    if (side == NSPositionBottom) {
                        side = NSPositionBottomRight;
                    } else {
                        side = NSPositionTopRight;
                    }
                }
            } else if (pointOnScreen.x + halfWidth >= NSMaxX(parentFrame)) {
                
                if (pointOnScreen.x - viewSize.width + arrowInset >= NSMinX(screenFrame)) {
                    
                    if (side == NSPositionBottom) {
                        side = NSPositionBottomLeft;
                    } else {
                        side = NSPositionTopLeft;
                    }
                }
            }
            break;
        case NSPositionRight:
        case NSPositionLeft:
            
            if (pointOnScreen.y - halfHeight < NSMinY(parentFrame)) {
                
                if (pointOnScreen.y + viewSize.height - arrowInset < NSMaxY(screenFrame)) {
                    
                    if (side == NSPositionRight) {
                        side = NSPositionRightTop;
                    } else {
                        side = NSPositionLeftTop;
                    }
                }
            } else if (pointOnScreen.y + halfHeight >= NSMaxY(parentFrame)) {
                
                if (pointOnScreen.y - viewSize.height + arrowInset >= NSMinY(screenFrame)) {
                    
                    if (side == NSPositionRight) {
                        side = NSPositionRightBottom;
                    } else {
                        side = NSPositionLeftBottom;
                    }
                }
            }
            break;
        default:
            break; 
    }
    
    return side;
}


- (float)_arrowInset
{
    float cornerInset = (drawsRoundCornerBesideArrow) ? cornerRadius : 0;
    return (cornerInset + (arrowBaseWidth / 2.0)) * NSFLoatingWindow_SCALE_FACTOR;
}


#pragma mark Drawing


- (void)_updateBackground
{
    NSDisableScreenUpdates();
    [super setBackgroundColor:[self _backgroundColorPatternImage]];
    if ([self isVisible]) {
        [self display];
        [self invalidateShadow];
    }
    NSEnableScreenUpdates();
}


- (NSColor *)_backgroundColorPatternImage
{
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    NSRect bgRect = NSZeroRect;
    bgRect.size = [bg size];
    
    [bg lockFocus];
    NSBezierPath *bgPath = [self _backgroundPath];
    [NSGraphicsContext saveGraphicsState];
    [bgPath addClip];
    
    [_NSBackgroundColor set];
    [bgPath fill];
    
    
    if (borderWidth > 0) {
        
        [bgPath setLineWidth:(borderWidth * 2.0) * NSFLoatingWindow_SCALE_FACTOR];
        [borderColor set];
        [bgPath stroke];
    }
    
    [NSGraphicsContext restoreGraphicsState];
    [bg unlockFocus];
    
    return [NSColor colorWithPatternImage:[bg autorelease]];
}


- (NSBezierPath *)_backgroundPath
{
    
    float scaleFactor = NSFLoatingWindow_SCALE_FACTOR;
    float scaledRadius = cornerRadius * scaleFactor;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    NSRect contentArea = NSInsetRect(_viewFrame,
                                     -viewMargin * scaleFactor,
                                     -viewMargin * scaleFactor);
    float minX = ceilf(NSMinX(contentArea) * scaleFactor + 0.5f);
	float midX = NSMidX(contentArea) * scaleFactor;
	float maxX = floorf(NSMaxX(contentArea) * scaleFactor - 0.5f);
	float minY = ceilf(NSMinY(contentArea) * scaleFactor + 0.5f);
	float midY = NSMidY(contentArea) * scaleFactor;
	float maxY = floorf(NSMaxY(contentArea) * scaleFactor - 0.5f);
	
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    
    NSPoint currPt = NSMakePoint(minX, maxY);
    if (scaledRadius > 0 &&
        (drawsRoundCornerBesideArrow || 
         (_side != NSPositionBottomRight && _side != NSPositionRightBottom)) 
        ) {
        currPt.x += scaledRadius;
    }
    
    NSPoint endOfLine = NSMakePoint(maxX, maxY);
    BOOL shouldDrawNextCorner = NO;
    if (scaledRadius > 0 &&
        (drawsRoundCornerBesideArrow || 
         (_side != NSPositionBottomLeft && _side != NSPositionLeftBottom)) 
        ) {
        endOfLine.x -= scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    [path moveToPoint:currPt];
    
    
    if (_side == NSPositionBottomRight) {
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionBottom) {
        
        [path lineToPoint:NSMakePoint(midX - halfArrowWidth, maxY)];
        
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionBottomLeft) {
        
        [path lineToPoint:NSMakePoint(endOfLine.x - scaledArrowWidth, maxY)];
        
        [self _appendArrowToPath:path];
    }
    
    
    [path lineToPoint:endOfLine];
    
    
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                       toPoint:NSMakePoint(maxX, maxY - scaledRadius) 
                                        radius:scaledRadius];
    }
    
    
    
    endOfLine = NSMakePoint(maxX, minY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 &&
        (drawsRoundCornerBesideArrow || 
         (_side != NSPositionTopLeft && _side != NSPositionLeftTop)) 
        ) {
        endOfLine.y += scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    
    if (_side == NSPositionLeftBottom) {
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionLeft) {
        
        [path lineToPoint:NSMakePoint(maxX, midY + halfArrowWidth)];
        
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionLeftTop) {
        
        [path lineToPoint:NSMakePoint(maxX, endOfLine.y + scaledArrowWidth)];
        
        [self _appendArrowToPath:path];
    }
    
    
    [path lineToPoint:endOfLine];
    
    
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                       toPoint:NSMakePoint(maxX - scaledRadius, minY) 
                                        radius:scaledRadius];
    }
    
    
    
    endOfLine = NSMakePoint(minX, minY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 &&
        (drawsRoundCornerBesideArrow || 
         (_side != NSPositionTopRight && _side != NSPositionRightTop)) 
        ) {
        endOfLine.x += scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    
    if (_side == NSPositionTopLeft) {
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionTop) {
        
        [path lineToPoint:NSMakePoint(midX + halfArrowWidth, minY)];
        
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionTopRight) {
        
        [path lineToPoint:NSMakePoint(endOfLine.x + scaledArrowWidth, minY)];
        
        [self _appendArrowToPath:path];
    }
    
    
    [path lineToPoint:endOfLine];
    
    
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                       toPoint:NSMakePoint(minX, minY + scaledRadius) 
                                        radius:scaledRadius];
    }
    
    
    
    endOfLine = NSMakePoint(minX, maxY);
    shouldDrawNextCorner = NO;
    if (scaledRadius > 0 &&
        (drawsRoundCornerBesideArrow || 
         (_side != NSPositionRightBottom && _side != NSPositionBottomRight)) 
        ) {
        endOfLine.y -= scaledRadius;
        shouldDrawNextCorner = YES;
    }
    
    
    if (_side == NSPositionRightTop) {
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionRight) {
        
        [path lineToPoint:NSMakePoint(minX, midY - halfArrowWidth)];
        
        [self _appendArrowToPath:path];
    } else if (_side == NSPositionRightBottom) {
        
        [path lineToPoint:NSMakePoint(minX, endOfLine.y - scaledArrowWidth)];
        
        [self _appendArrowToPath:path];
    }
    
    
    [path lineToPoint:endOfLine];
    
    
    if (shouldDrawNextCorner) {
        [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                       toPoint:NSMakePoint(minX + scaledRadius, maxY) 
                                        radius:scaledRadius];
    }
    
    [path closePath];
    return path;
}


- (void)_appendArrowToPath:(NSBezierPath *)path
{
    if (!hasArrow) {
        return;
    }
    
    float scaleFactor = NSFLoatingWindow_SCALE_FACTOR;
    float scaledArrowWidth = arrowBaseWidth * scaleFactor;
    float halfArrowWidth = scaledArrowWidth / 2.0;
    float scaledArrowHeight = arrowHeight * scaleFactor;
    NSPoint currPt = [path currentPoint];
    NSPoint tipPt = currPt;
    NSPoint endPt = currPt;
    
    
    switch (_side) {
        case NSPositionLeft:
        case NSPositionLeftTop:
        case NSPositionLeftBottom:
            
            tipPt.x += scaledArrowHeight;
            tipPt.y -= halfArrowWidth;
            endPt.y -= scaledArrowWidth;
            break;
        case NSPositionRight:
        case NSPositionRightTop:
        case NSPositionRightBottom:
            
            tipPt.x -= scaledArrowHeight;
            tipPt.y += halfArrowWidth;
            endPt.y += scaledArrowWidth;
            break;
        case NSPositionTop:
        case NSPositionTopLeft:
        case NSPositionTopRight:
            
            tipPt.y -= scaledArrowHeight;
            tipPt.x -= halfArrowWidth;
            endPt.x -= scaledArrowWidth;
            break;
        case NSPositionBottom:
        case NSPositionBottomLeft:
        case NSPositionBottomRight:
            
            tipPt.y += scaledArrowHeight;
            tipPt.x += halfArrowWidth;
            endPt.x += scaledArrowWidth;
            break;
        default:
            break;
    }
    
    [path lineToPoint:tipPt];
    [path lineToPoint:endPt];
}


- (void)_redisplay
{
    if (_resizing) {
        return;
    }
    
    _resizing = YES;
    NSDisableScreenUpdates();
    [self _updateGeometry];
    [self _updateBackground];
    NSEnableScreenUpdates();
    _resizing = NO;
}


# pragma mark Window Behaviour


- (BOOL)canBecomeMainWindow
{
    return NO;
}


- (BOOL)canBecomeKeyWindow
{
    return YES;
}


- (BOOL)isExcludedFromWindowsMenu
{
    return YES;
}


- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if (_window) {
        return [_window validateMenuItem:item];
    }
    return [super validateMenuItem:item];
}


- (IBAction)performClose:(id)sender
{
    if (_window) {
        [_window performClose:sender];
    } else {
        [super performClose:sender];
    }
}


# pragma mark Notification handlers


- (void)windowDidResize:(NSNotification *)note
{
    [self _redisplay];
}


#pragma mark Accessors


- (void)setPoint:(NSPoint)point side:(NSWindowPosition)side
{
    
	_point = point;
	_side = side;
	NSDisableScreenUpdates();
	[self _updateGeometry];
	[self _updateBackground];
	NSEnableScreenUpdates();
}


- (NSColor *)windowBackgroundColor {
    return [[_NSBackgroundColor retain] autorelease];
}


- (void)setBackgroundColor:(NSColor *)value {
    if (_NSBackgroundColor != value) {
        [_NSBackgroundColor release];
        _NSBackgroundColor = [value copy];
        
        [self _updateBackground];
    }
}


- (NSColor *)borderColor {
    return [[borderColor retain] autorelease];
}


- (void)setBorderColor:(NSColor *)value {
    if (borderColor != value) {
        [borderColor release];
        borderColor = [value copy];
        
        [self _updateBackground];
    }
}


- (float)borderWidth {
    return borderWidth;
}


- (void)setBorderWidth:(float)value {
    if (borderWidth != value) {
        float maxBorderWidth = viewMargin;
        if (value <= maxBorderWidth) {
            borderWidth = value;
        } else {
            borderWidth = maxBorderWidth;
        }
        
        [self _updateBackground];
    }
}


- (float)viewMargin {
    return viewMargin;
}


- (void)setViewMargin:(float)value {
    if (viewMargin != value) {
        viewMargin = MAX(value, 0.0);
        
        
        [self setCornerRadius:cornerRadius];
    }
}


- (float)arrowBaseWidth {
    return arrowBaseWidth;
}


- (void)setArrowBaseWidth:(float)value {
    float maxWidth = (MIN(_viewFrame.size.width, _viewFrame.size.height) + 
                      (viewMargin * 2.0)) - cornerRadius;
    if (drawsRoundCornerBesideArrow) {
        maxWidth -= cornerRadius;
    }
    if (value <= maxWidth) {
        arrowBaseWidth = value;
    } else {
        arrowBaseWidth = maxWidth;
    }
    
    [self _redisplay];
}


- (float)arrowHeight {
    return arrowHeight;
}


- (void)setArrowHeight:(float)value {
    if (arrowHeight != value) {
        arrowHeight = value;
        
        [self _redisplay];
    }
}


- (float)hasArrow {
    return hasArrow;
}


- (void)setHasArrow:(float)value {
    if (hasArrow != value) {
        hasArrow = value;
        
        [self _updateBackground];
    }
}


- (float)cornerRadius {
    return cornerRadius;
}


- (void)setCornerRadius:(float)value {
    float maxRadius = ((MIN(_viewFrame.size.width, _viewFrame.size.height) + 
                        (viewMargin * 2.0)) - arrowBaseWidth) / 2.0;
    if (value <= maxRadius) {
        cornerRadius = value;
    } else {
        cornerRadius = maxRadius;
    }
    cornerRadius = MAX(cornerRadius, 0.0);
    
    
    [self setArrowBaseWidth:arrowBaseWidth];
}


- (float)drawsRoundCornerBesideArrow {
    return drawsRoundCornerBesideArrow;
}


- (void)setDrawsRoundCornerBesideArrow:(float)value {
    if (drawsRoundCornerBesideArrow != value) {
        drawsRoundCornerBesideArrow = value;
        
        [self _redisplay];
    }
}


- (void)setBackgroundImage:(NSImage *)value
{
    if (value) {
        [self setBackgroundColor:[NSColor colorWithPatternImage:value]];
    }
}


@end
