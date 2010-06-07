//
//  SFTabView.m
//  tabtest
//
//  Created by Matteo Rattotti on 2/27/10.
//  Copyright 2010 www.shinyfrog.net. All rights reserved.
//

#import "SFTabView.h"

@implementation SFTabView

@synthesize delegate, defaultTabClassName;
@synthesize startingOffset, tabOffset, tabMagneticForce;

#pragma mark -
#pragma mark Constructors

- (void) awakeFromNib {
        
        [self setDefaults];

}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

#pragma mark -
#pragma mark Defaults

- (void) setDefaults {
    CALayer *bgLayer = [CALayer layer];
    bgLayer.frame = NSRectToCGRect([self bounds]);
    bgLayer.layoutManager = [CAConstraintLayoutManager layoutManager];

    [self setLayer:bgLayer];
    [self setWantsLayer:YES];
    
    [self.layer addSublayer:[self scrollLayer]];
    
    arrangedTabs = [[NSMutableArray alloc]init];
    tabOffset = 0;
    startingOffset = 0;
    tabMagneticForce = 5;
    defaultTabClassName = @"SFDefaultTab";
   
    [self setupObservers];
}

#pragma mark -
#pragma mark Obververs

- (void) setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                         selector:@selector(frameDidChange:) 
                                             name:NSViewFrameDidChangeNotification 
                                           object:self];
}

- (void) frameDidChange: (id) sender {
	[self adjustTabLayerScrollAnimated:NO];
}

- (void) adjustTabLayerScrollAnimated: (BOOL) animated {
	if (currentSelectedTab == nil) {
		return;
	}
	
	CGRect currentSelFrame = currentSelectedTab.frame;
    currentSelFrame.size.width += currentSelFrame.size.width / 2.0;
	
    // Scrolling to maintain the selected tab visible
    if(!CGRectContainsRect(tabsLayer.visibleRect, currentSelFrame)) {
        [self scrollToTab:currentSelectedTab animated: NO];
	}
    
    // eventually scrolling back if the tabview frame expanded
    if(tabsLayer.visibleRect.size.width < ([self bounds].size.width - ([self lastTab].frame.size.width / 2.0)) && tabsLayer.visibleRect.origin.x > 0) {
        float deltaX =  ([self bounds].size.width - ([self lastTab].frame.size.width / 2.0)) - tabsLayer.visibleRect.size.width;
        
        float newTabXPosition = tabsLayer.visibleRect.origin.x - deltaX;
        if (newTabXPosition < 0) {
            newTabXPosition = 0;
        }
		
		[self scrollToPoint:CGPointMake(newTabXPosition,0) animated:animated];
	}	
	
}

#pragma mark -
#pragma mark Base Layers

- (CALayer *) tabsLayer {
    tabsLayer = [CALayer layer];
    tabsLayer.name = @"tabsLayer";
    
    tabsLayer.layoutManager = [CAConstraintLayoutManager layoutManager];

    [tabsLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];
    [tabsLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
    [tabsLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];

    NSMutableDictionary *actions=[NSMutableDictionary dictionaryWithDictionary:[tabsLayer actions]];
    [actions setObject:[NSNull null] forKey:@"onOrderIn"];
    [actions setObject:[NSNull null] forKey:@"onOrderOut"];
    [actions setObject:[NSNull null] forKey:@"position"];
    [actions setObject:[NSNull null] forKey:@"bounds"];
    [actions setObject:[NSNull null] forKey:@"contents"];
    [actions setObject:[NSNull null] forKey:@"sublayers"];
	 
    [tabsLayer setActions:actions];
    
    return tabsLayer;
}

- (CAScrollLayer *) scrollLayer {
    scrollLayer = [CAScrollLayer layer];
    scrollLayer.name = @"scrollLayer";
    
    scrollLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX]];
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX]];
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY]];
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY]];
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth]];
    [scrollLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];

    NSMutableDictionary *actions=[NSMutableDictionary dictionaryWithDictionary:[scrollLayer actions]];
    [actions setObject:[NSNull null] forKey:@"position"];
    [actions setObject:[NSNull null] forKey:@"bounds"];
    [actions setObject:[NSNull null] forKey:@"sublayers"];
    [actions setObject:[NSNull null] forKey:@"contents"];

    [scrollLayer setActions:actions];

    [scrollLayer addSublayer:[self tabsLayer]];
    
    return scrollLayer;
}

#pragma mark -
#pragma mark Mouse Handling

- (void)mouseDown: (NSEvent *) theEvent {
    // Getting clicked point.
    NSPoint mousePointInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    mousePointInView = [self.layer convertPoint:mousePointInView toLayer:tabsLayer];
    mouseDownPoint = mousePointInView;
    
    // Checking if a tab was clicked.
    CALayer *clickedLayer = [tabsLayer hitTest:mousePointInView];

    if (clickedLayer &&  clickedLayer != tabsLayer ) {
        canDragTab = NO;
        BOOL shouldSelectTab = YES;
        
        // Asking delegate if the tab can be selected.
        if ([delegate respondsToSelector:@selector(tabView:shouldSelectTab:)]) {
            shouldSelectTab = [delegate tabView:self shouldSelectTab:clickedLayer];
        }
        if (shouldSelectTab) {
            [self selectTab:clickedLayer];        
            mouseDownStartingPoint = currentSelectedTab.frame.origin;
            currentClickedTab = clickedLayer;
        }
        
    }

}

- (void)mouseDragged: (NSEvent *) theEvent {
    // convert to local coordinate system
    NSPoint mousePointInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
        mousePointInView = [self.layer convertPoint:mousePointInView toLayer:tabsLayer];

    if (currentClickedTab) {
        NSPoint deltaPoint = [self deltaFromStartingPoint:mouseDownPoint endPoint:mousePointInView];
        
        // Getting drag direction, positive value mean right.
        BOOL rightShift = (deltaPoint.x > 0);

        // Applying magnetic force, prevent dragging tab if the drag distance is < than tabMagneticForce.
        if (rightShift && mousePointInView.x > mouseDownPoint.x + tabMagneticForce)
            canDragTab = YES;
        else if (mousePointInView.x < mouseDownPoint.x - tabMagneticForce)
            canDragTab = YES;
        
        if (!canDragTab)
            return;

        CGPoint tabNewOrigin = CGPointMake(currentClickedTab.frame.origin.x + deltaPoint.x, currentClickedTab.frame.origin.y);
        CGRect newFrame = currentClickedTab.frame;
        
        
        // Checking if the dragged tab crossed another tab.
        CGPoint proximityLayerPoint;
        
        if(rightShift)
            proximityLayerPoint = CGPointMake(tabNewOrigin.x + (currentClickedTab.frame.size.width), tabNewOrigin.y);
        else {
            proximityLayerPoint = CGPointMake(tabNewOrigin.x, tabNewOrigin.y);
        }

        CALayer *la = [tabsLayer hitTest:proximityLayerPoint];
        
        // if the drag is outside the tabview range we'll adjust the crossed tab to be the first or the last.
        if ((!la || la == tabsLayer) && proximityLayerPoint.x < startingOffset) {
            la = [self firstTab];
        }
        else if ((!la || la == tabsLayer) && proximityLayerPoint.x > [[self lastTab] frame].size.width + [[self lastTab] frame].origin.x) {
            la = [self lastTab];
        }
        
        // If the tab is different than the tab view layer and than the selected one we'll rearrange tabs.
        if(la && la != currentClickedTab && la != tabsLayer) {
            

            [self rearrangeInitialTab:currentClickedTab toLandingTab:la withCurrentPoint:proximityLayerPoint direction:rightShift];

        }         
        
        // Moving the dragged tab according.
        newFrame.origin.x = tabNewOrigin.x;
        if (newFrame.origin.x < startingOffset) 
            newFrame.origin.x = startingOffset;
        else if(newFrame.origin.x + newFrame.size.width > tabsLayer.frame.size.width)
            newFrame.origin.x = tabsLayer.frame.size.width - newFrame.size.width;
        

            
        if(CGRectContainsRect(/*NSRectToCGRect([self bounds])*/tabsLayer.frame, newFrame)){
            [CATransaction begin]; 
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            currentClickedTab.frame= newFrame;
            [CATransaction commit];
            mouseDownPoint = mousePointInView;
        }
    }

    
}

- (void)mouseUp: (NSEvent *) theEvent {
    if (currentClickedTab) {
    
        // On mouse up we let the dragged tab slide to the starting or changed position.
        CGRect newFrame = currentClickedTab.frame;
        newFrame.origin.x = mouseDownStartingPoint.x;
        
        currentClickedTab.frame = newFrame;
        currentClickedTab = nil;
    }
    
    [self scrollToTab:currentSelectedTab];
   
}

#pragma mark -
#pragma mark Adding and Removing Tabs

- (void) addTabWithRepresentedObject: (id) representedObject {
	[self addTabAtIndex:[self numberOfTabs] withRepresentedObject:representedObject];
}

- (void) addTabAtIndex: (int) index withRepresentedObject: (id) representedObject {
    // Loading the class that will render the tab layer.
    Class tabLayerClass = [[NSBundle mainBundle] classNamed: defaultTabClassName];
    id newtab = [tabLayerClass layer];
    
    // Passing the represented object to the tab layer.
    if ([newtab respondsToSelector:@selector(setRepresentedObject:)]) {
        [newtab setRepresentedObject:representedObject];
    }
    
    // Removing animation for z-index changes.
    NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[newtab actions]];
    [customActions setObject:[NSNull null] forKey:@"zPosition"];
    [newtab setActions:customActions];

    // Setting up new tab.
    [newtab setFrame: CGRectMake([self startingXOriginForTabAtIndex:index], 0, [newtab frame].size.width, [newtab frame].size.height)];
	[newtab setZPosition:  (float)index * -1 ];

	if ([self numberOfTabs] > 0 && index <= [self numberOfTabs]-1) {
		// Getting the right tag sequence (left-to-right).
		NSArray *tabsSequence = [self tabSequenceForStartingTabIndex:index-1 endingTabIndex:[self numberOfTabs]-1 direction:YES];
		
		// shifting pre-existing tabs according
		for(NSNumber *n in tabsSequence){
			CALayer *landingTab = [self tabAtIndex:[n intValue]];
			
			// Updating z-index
			if (![landingTab isEqualTo:currentSelectedTab]) {
				landingTab.zPosition = (float)([n intValue]+1) * -1;
			}
			
			// Moving a tab.
			CGRect newFrame = landingTab.frame;
			newFrame.origin.x += [newtab frame].size.width + tabOffset;
			landingTab.frame = newFrame;
		}
	}
	
    [tabsLayer addSublayer:newtab];
    [arrangedTabs insertObject:newtab atIndex:index];

    // Selecting it if it's the only one.
    if ([self numberOfTabs] == 1) {
        [self selectTab:newtab];
    }
    
    int offset = tabOffset;
    if ([self numberOfTabs] == 1) {
        offset = startingOffset;
	}
    
    // adjusting the size of the tabsLayer
    [tabsLayer setValue:[NSNumber numberWithInt:[newtab frame].size.width + tabsLayer.frame.size.width + offset]  forKeyPath: @"frame.size.width"];
    
	// Notifing delegate
	if ([delegate respondsToSelector:@selector(tabView:didAddTab:)]) {
		[delegate tabView:self didAddTab:newtab];
	}
}

- (void) removeTab: (CALayer *) tab {
    int tabIndex = [self indexOfTab:tab];
    if (tabIndex != -1) {
        [self removeTabAtIndex:tabIndex];
    }
}

- (void) removeTabAtIndex: (int) index {

    // Grabbing the tab.
    int indexOfInitialTab = index;
    CALayer *tab = [arrangedTabs objectAtIndex:indexOfInitialTab];
    CGPoint startingOrigin = tab.frame.origin;
    int indexOfLandingTab = [arrangedTabs count] -1;
    
	
    int newIndex = indexOfInitialTab; //- 1;

	if ([tab isEqualTo:[self lastTab]] && ![tab isEqualTo:[self firstTab]]) {
		[self selectTab: [self tabAtIndex:indexOfLandingTab - 1]];
	}
	else if([tab isEqualTo:[self firstTab]] && [tab isEqualTo:[self lastTab]]){
		currentSelectedTab = nil;
	}
	
	// Getting the right tag sequence (left-to-right).
	NSArray *tabsSequence = [self tabSequenceForStartingTabIndex:indexOfInitialTab endingTabIndex:indexOfLandingTab direction:YES];

	// Sliding all right tabs to the left.
	for(NSNumber *n in tabsSequence){
		CALayer *landingTab = [self tabAtIndex:[n intValue]];//[arrangedTabs objectAtIndex:[n intValue]];

		// If the deleted tag was the selected one we'll switch selection on the successive.
		if ([tab isEqualTo:currentSelectedTab]) {
			[self selectTab:landingTab];
		}
		// Adjusting the zPosition of moved tab (only if it's not selected).
		else if([landingTab isNotEqualTo:currentSelectedTab]){
			++newIndex;
			landingTab.zPosition = (float)newIndex * -1;
		}

		// Moving a tab.
		CGRect newFrame = CGRectMake(startingOrigin.x, startingOrigin.y, landingTab.frame.size.width , landingTab.frame.size.height);
		landingTab.frame = newFrame;
		startingOrigin.x += newFrame.size.width + tabOffset;
	}

    // Removing the frame from the view layer without animating.
    [CATransaction begin]; 
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    [tab removeFromSuperlayer];
    [CATransaction commit];

	
	int offset = tabOffset;
    if ([self numberOfTabs] == 1) {
        offset = startingOffset;
	}
	
	// adjusting the size of the tabsLayer
    [tabsLayer setValue:[NSNumber numberWithInt: tabsLayer.frame.size.width - ([tab frame].size.width + offset)]  forKeyPath: @"frame.size.width"];

	if ([delegate respondsToSelector:@selector(tabView:didRemovedTab:)]) {
		[delegate tabView:self didRemovedTab: tab];
	}
	
    // Removing tab from the arranged tags.
    [arrangedTabs removeObject:tab];

	[self adjustTabLayerScrollAnimated:YES];
}

#pragma mark -
#pragma mark Accessing Tabs

- (int) indexOfTab: (CALayer *) tab {
    return [arrangedTabs indexOfObject:tab];
}

- (int) numberOfTabs {
    return [arrangedTabs count];
}

- (CALayer *) tabAtIndex: (int) index {
    return [arrangedTabs objectAtIndex:index];
}

- (NSArray *) arrangedTabs {
    return arrangedTabs;
}

- (CALayer *) firstTab {
    return [arrangedTabs objectAtIndex:0];
}

- (CALayer *) lastTab {
    return [arrangedTabs lastObject];
}

#pragma mark -
#pragma mark Selecting a Tab

- (void) selectTab: (CALayer *) tab {
	
	if (![arrangedTabs containsObject:tab]) {
		return;
	}
	
    if ([delegate respondsToSelector:@selector(tabView:willSelectTab:)]) {
        [delegate tabView:self willSelectTab:tab];
    }
    
    if(currentSelectedTab){

        currentSelectedTab.zPosition = ([self indexOfTab:currentSelectedTab] * -1.0);            
        if ([currentSelectedTab respondsToSelector:@selector(setSelected:)]) {
            [(id)currentSelectedTab setSelected: NO];
        }
        currentSelectedTab = nil;
    }

    currentSelectedTab = tab;
    
    currentSelectedTab.zPosition = 1000;

    if ([currentSelectedTab respondsToSelector:@selector(setSelected:)]) {
        [(id)currentSelectedTab setSelected: YES];
    }
    
    if ([delegate respondsToSelector:@selector(tabView:didSelectTab:)]) {
        [delegate tabView:self didSelectTab:tab];
    }   
    
    [self scrollToTab:currentSelectedTab];

}

- (void) selectTabAtIndex: (unsigned int) index {
    [self selectTab: [self tabAtIndex:index]];
}

- (void) selectFirstTab: (id) sender {
    [self selectTab: [self firstTab]];
}

- (void) selectLastTab: (id) sender {
    [self selectTab: [self lastTab]];
}

- (void) selectNextTab: (id) sender {
    unsigned int currentTabIndex = [ self indexOfTab: [self selectedTab] ];
    int nextIndex = currentTabIndex + 1;
    if (currentTabIndex == [self numberOfTabs] -1 )
        nextIndex = 0;
    
    [self selectTabAtIndex: nextIndex];
}

- (void) selectPreviousTab: (id) sender {
    unsigned int currentTabIndex = [ self indexOfTab: [self selectedTab] ];
    int prevIndex = currentTabIndex - 1;
    if (currentTabIndex == 0 )
        prevIndex = [self numberOfTabs] -1;
    
    [self selectTabAtIndex: prevIndex];
}

- (CALayer *) selectedTab {
    return currentSelectedTab;
}

#pragma mark -
#pragma mark Scrolling

- (void) scrollToTab: (CALayer *) tab {
    [self scrollToTab:tab animated:YES];
}


- (void) scrollToTab: (CALayer *) tab animated: (BOOL) animated{
	NSMutableDictionary *actions=[NSMutableDictionary dictionaryWithDictionary:[scrollLayer actions]];
	[actions removeObjectForKey:@"position"];
	[actions removeObjectForKey:@"bounds"];
	
	float duration = 0.0f;
	if (animated) {
		duration = 0.4f;
	}
	
	[ CATransaction begin ];
	[ CATransaction setValue: [ NSNumber numberWithFloat:duration] forKey:@"animationDuration" ];
	
	
	[scrollLayer setActions:actions];
	
	
	CGRect newFrame = tab.frame;
	if ([tab isNotEqualTo:[self firstTab]] /*&& [tab isNotEqualTo:[self lastTab]]*/) {
		newFrame.origin.x -= newFrame.size.width / 2.0;
		newFrame.size.width += newFrame.size.width;
	}
	else if([tab isEqualTo:[self firstTab]]) {
		newFrame.origin.x -= startingOffset;
	}
	[tabsLayer scrollRectToVisible:newFrame];
	
	[ CATransaction commit ];
	
	[actions setObject:[NSNull null] forKey:@"position"];
	[actions setObject:[NSNull null] forKey:@"bounds"];
	[scrollLayer setActions:actions];
	
}

- (void) scrollToPoint: (CGPoint) point animated: (BOOL) animated{
	NSMutableDictionary *actions=[NSMutableDictionary dictionaryWithDictionary:[scrollLayer actions]];
	[actions removeObjectForKey:@"position"];
	[actions removeObjectForKey:@"bounds"];
	
	float duration = 0.0f;
	if (animated) {
		duration = 0.4f;
	}
	
	[ CATransaction begin ];
	[ CATransaction setValue: [ NSNumber numberWithFloat:duration] forKey:@"animationDuration" ];
	
	
	[scrollLayer setActions:actions];
	
	[tabsLayer scrollPoint:point];
	
	[ CATransaction commit ];
	
	[actions setObject:[NSNull null] forKey:@"position"];
	[actions setObject:[NSNull null] forKey:@"bounds"];
	[scrollLayer setActions:actions];
	
}

	
#pragma mark -
#pragma mark Tab Handling



- (void) rearrangeInitialTab: (CALayer *) initialTab toLandingTab:(CALayer *) landingTab withCurrentPoint: (CGPoint) currentPoint direction: (BOOL) direction{
    int indexOfInitialTab = [self indexOfTab:initialTab];
    int indexOfLandingTab = [self indexOfTab:landingTab];
    
    
    // Getting the right tag sequence (left-to-right or right-to-left)
    NSArray *tabsSequence = [self tabSequenceForStartingTabIndex:indexOfInitialTab endingTabIndex:indexOfLandingTab direction:direction];

    for(NSNumber *n in tabsSequence){
        landingTab = [self tabAtIndex:[n intValue]];

        int newIndex = 0;
        int landingOriginOffset = 0;
        int initialOriginOffset = 0;
        
        // We are moving left to right, so the origin of the selected tab should be updated.
        if (direction && currentPoint.x >= landingTab.position.x ) {    
            newIndex = indexOfInitialTab + 1;

            landingOriginOffset = landingTab.frame.size.width - initialTab.frame.size.width;
            [self scrollToTab:currentSelectedTab];
        }
        
        // Moving right to left, the origin of the moved (not selected) tab should be updated. 
        else if(!direction && currentPoint.x < landingTab.position.x ){
            newIndex = indexOfInitialTab - 1;

            initialOriginOffset = landingTab.frame.size.width - initialTab.frame.size.width;
            [self scrollToTab:currentSelectedTab];

        }
        else {
            continue;
        }

        // Swapping indexes of initial tab and landing tab
        [arrangedTabs removeObjectAtIndex:indexOfInitialTab];
        [arrangedTabs insertObject:initialTab atIndex:newIndex];
        
        landingTab.zPosition = indexOfInitialTab * -1;

        indexOfInitialTab = newIndex;


        // If the tab are of different size we need to adjust the new origin point.
        CGPoint landingOrigin = landingTab.frame.origin;
        landingOrigin.x += landingOriginOffset;

        CGRect newFrame = CGRectMake(mouseDownStartingPoint.x - initialOriginOffset, mouseDownStartingPoint.y, landingTab.frame.size.width , landingTab.frame.size.height);

        landingTab.frame = newFrame;
        mouseDownStartingPoint = landingOrigin;
        
    }
        
}

#pragma mark -
#pragma mark Utility methods

/* Return a correctly ordered (depepending on direction) tab indexes array */
- (NSArray *) tabSequenceForStartingTabIndex: (int) startingIndex endingTabIndex: (int) endingIndex direction: (BOOL) direction {
    NSMutableArray *tagsSequence = [NSMutableArray array];
    
    for (int i = MIN(startingIndex, endingIndex); i<=MAX(startingIndex, endingIndex); i++) {
        if (i == startingIndex)
            continue;
        else if (direction)
            [tagsSequence addObject:[NSNumber numberWithInt:i]];
        else
            [tagsSequence insertObject:[NSNumber numberWithInt:i] atIndex:0];
    }

    return tagsSequence;
}


/* Return the initial x coordinate for a new tab */
- (int) startingXOriginForTabAtIndex: (int) index {
    if (index == 0)
        return startingOffset;
    else
		return [[self tabAtIndex: index-1] frame].origin.x + [[self tabAtIndex:index-1] frame].size.width + tabOffset; 
}

- (NSPoint) deltaFromStartingPoint:(NSPoint)startingPoint endPoint:(NSPoint) endPoint {
    return NSMakePoint(endPoint.x - startingPoint.x, endPoint.y - startingPoint.y);
}

/* basic animation for moving tabs */
- (CABasicAnimation *) tabMovingAnimation {
    CABasicAnimation *slideAnimation = [CABasicAnimation animation];
    slideAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return slideAnimation;
}


@end
