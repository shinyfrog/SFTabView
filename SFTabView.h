//
//  SFTabView.h
//  tabtest
//
//  Created by Matteo Rattotti on 2/27/10.
//  Copyright 2010 www.shinyfrog.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@protocol SFTabViewDelegate;

@interface SFTabView : NSView {
    IBOutlet NSObject  <SFTabViewDelegate> *delegate;

    CALayer *currentClickedTab;
    CALayer *currentSelectedTab;

    CALayer *tabsLayer;
    CAScrollLayer *scrollLayer;
    
    NSMutableArray *arrangedTabs;
    NSPoint mouseDownPoint, mouseDownStartingPoint;
    
    NSString *defaultTabClassName;
    
    BOOL canDragTab;
    
    int tabOffset;
    int startingOffset;
    int tabMagneticForce;
}

@property (retain) id delegate;
@property (retain) NSString *defaultTabClassName;

@property int tabOffset;
@property int startingOffset;
@property int tabMagneticForce;


#pragma mark -
#pragma mark Adding and Removing Tabs

- (void) addTabWithRepresentedObject: (id) representedObject;
- (void) addTabAtIndex: (int) index withRepresentedObject: (id) representedObject;
- (void) removeTab: (CALayer *) tab;
- (void) removeTabAtIndex: (int) index;

#pragma mark -
#pragma mark Accessing Tabs

- (int) indexOfTab: (CALayer *) tab;
- (int) numberOfTabs;

- (CALayer *) tabAtIndex: (int) index;
- (NSArray *) arrangedTabs;
- (CALayer *) firstTab;
- (CALayer *) lastTab;

#pragma mark -
#pragma mark Selecting a Tab

- (void) selectTab: (CALayer *) tab;
- (void) selectTabAtIndex: (unsigned int) index;
- (void) selectFirstTab: (id) sender;
- (void) selectLastTab: (id) sender;
- (void) selectNextTab: (id) sender;
- (void) selectPreviousTab: (id) sender;
- (CALayer *) selectedTab;

#pragma mark -
#pragma mark Scrolling

- (void) scrollToTab: (CALayer *) tab;
- (void) scrollToTab: (CALayer *) tab animated: (BOOL) animated;
- (void) scrollToPoint: (CGPoint) point animated: (BOOL) animated;

@end

#pragma mark -
#pragma mark Private Methods

@interface SFTabView (Private)

- (CALayer *) tabsLayer;
- (CAScrollLayer *) scrollLayer;

- (void) setupObservers;
- (void) setDefaults;
- (void) adjustTabLayerScrollAnimated: (BOOL) animated;
- (void) rearrangeInitialTab: (CALayer *) initialTab toLandingTab:(CALayer *) landingTab withCurrentPoint: (CGPoint) currentPoint direction: (BOOL) direction;

- (NSArray *) tabSequenceForStartingTabIndex: (int) startingIndex endingTabIndex: (int) endingIndex direction: (BOOL) direction;
- (int) startingXOriginForTabAtIndex: (int) index;
- (CABasicAnimation *) tabMovingAnimation;
- (NSPoint) deltaFromStartingPoint:(NSPoint)startingPoint endPoint:(NSPoint) endPoint;

@end


#pragma mark -
#pragma mark SFTabView Delegate protocol

@protocol SFTabViewDelegate

- (BOOL)tabView:(SFTabView *)tabView shouldSelectTab:(CALayer *)tab;
- (void)tabView:(SFTabView *)tabView didSelectTab:(CALayer *)tab;
- (void)tabView:(SFTabView *)tabView willSelectTab:(CALayer *)tab;
- (void)tabView:(SFTabView *)tabView didAddTab:(CALayer *)tab;
- (void)tabView:(SFTabView *)tabView didRemovedTab:(CALayer *)tab;

@end
