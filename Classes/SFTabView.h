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

/**
 An SFTabView provides a convenient way to manage tabs in your application. 
 The view contains a row of tabs that can be selected one at time and reordered by dragging.
 
 The SFTabViewAppDelegate protocol will notify the delegate during notable Tab View events, 
 like selecting, adding and deleting tabs.
 
 The tabs are rendered using a CALayer subclass, the Tab View will know which class to use by
 setting the defaultTabClassName property.
  
*/

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

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////


/** 
 @brief The SFTabView Delegate.
 
 */
@property (retain) id delegate;


/** 
 @brief The CALayer subclass that will render a single tab.
 
 This class should be conform to the SFTab protocoll.  
 */
@property (retain) NSString *defaultTabClassName;


/** 
 @brief The space between two tabs.

 This property can hold negative values in order to make tabs overlap. 
 
 This property should be only changed when the Tab Bar contain no tabs.
 */
@property int tabOffset;


/** 
 @brief The space before the first tab.
 
 The first tab will appear shifted to "startingOffset" pixel.
 
 This property should be only changed when the Tab Bar contain no tabs.

 */
@property int startingOffset;


/** 
 @brief The number of pixel that the user need to drag before the tab actually move.
 
 High value will make the tabs harder to move, a value of 0 will make the tab moving at
 every drag tentative.
 */
@property int tabMagneticForce;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Adding and Removing Tabs
//////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Adding and Removing Tabs

/** 
 @brief Add a new tab to the tabview, using the representedObject as model.
  
 @param representedObject An object passed to the CALayer subclass that contain all the in
 fomation needed for rendering the tab.
 @see addTabAtIndex:withRepresentedObject:
 
 */
- (void) addTabWithRepresentedObject: (id) representedObject;


/** 
 @brief Add a new tab to the tabview at the specified index, using the representedObject as model.
 
 @param index The index in the tabview at which to insert a new tab.
 @param representedObject An object passed to the CALayer subclass that contain all the in
 fomation needed for rendering the tab.
 @see addTabWithRepresentedObject:
 
 */
- (void) addTabAtIndex: (int) index withRepresentedObject: (id) representedObject;


/** 
 @brief Remove the tab from the tabview.
 
 @param tab The tab to remove from the tabview.
 @see removeTabAtIndex:
 
 */
- (void) removeTab: (CALayer *) tab;


/** 
 @brief Remove the tab at index.
 
 @param index The index from which to remove the object in the tabview.
 @see removeTab:
 
 */
- (void) removeTabAtIndex: (int) index;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Accessing Tabs
//////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Accessing Tabs


/** 
 @brief Returns the index corresponding to tab.
 
 Tabs are considered equal if isEqual: returns YES.
 
 @param tab A tab contained in the Tab View.
 @return The index whose corresponding tab object is equal to tab. If none of the objects in the tabview is equal to tab, returns NSNotFound.
 */
- (int) indexOfTab: (CALayer *) tab;


/** 
 @brief Returns the number of tab in the Tab View.
 */
- (int) numberOfTabs;


/**
 @brief Returns the tab located at index.
 
 If index is beyond the end of the Tab View (that is, if index is greater than or equal to the value returned by numberOfTabs), an NSRangeException is raised.
 
 @param index An index within the bounds of the Tab View.
 @return The tab located at index.
 @see numberOfTabs
 */
- (CALayer *) tabAtIndex: (int) index;


/** 
 @brief Returns an array contaning all the Tab View tabs.
 @return An array contaning all the Tab View tabs.
 */
- (NSArray *) arrangedTabs;


/** 
 @brief Returns the first tab in the Tab View.
 @return The first tab in the Tab View. If the Tab View contain no tabs, returns nil.
 */
- (CALayer *) firstTab;


/** 
 @brief Returns the last tab in the Tab View.
 @return The last tab in the Tab View. If the Tab View contain no tabs, returns nil.
 */
- (CALayer *) lastTab;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Selecting Tabs
//////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Selecting a Tab


/** 
 @brief Select the given tab in the tabview.
 @param tab A tab contained in the Tab View.
 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab:
 */
- (void) selectTab: (CALayer *) tab;


/** 
 @brief Select a tab at given index.
 @param index An index within the bounds of the Tab View.

 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab: 
 */
- (void) selectTabAtIndex: (unsigned int) index;


/** 
 @brief Select the first tab of the Tab View.
 @param sender Typically the object that sent the message.
 
 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab: 
 */
- (void) selectFirstTab: (id) sender;


/** 
 @brief Select the last tab of the Tab View
 @param sender Typically the object that sent the message.
 
 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab: 
 */
- (void) selectLastTab: (id) sender;


/** 
 @brief Select the tab on the right of the current selected tab.
 
 If the tab is the last one, the first tab of the Tab View will be selected, and
 the Tab View will be scrolled according.
 
 @param sender Typically the object that sent the message.
 
 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab: 
 */
- (void) selectNextTab: (id) sender;


/** 
 @brief Select the tab on the left of the current selected tab.
 
 If the tab is the first one, the last tab of the Tab View will be selected, and
 the Tab View will be scrolled according.
 
 @param sender Typically the object that sent the message.
 
 @see selectFirstTab:
 @see selectLastTab:
 @see selectNextTab:
 @see selectPreviousTab: 
 */
- (void) selectPreviousTab: (id) sender;


/** 
 @brief Returns the current selected tab.
 @return The current selected tab in the Tab View. If the Tab View contain no tabs, returns nil.
 */
- (CALayer *) selectedTab;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Scrolling
//////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Scrolling


/** 
 @brief Scroll the Tab View until tab is fully visibile.
 @param tab A tab contained in the Tab View.
 
 This method will scroll the Tab View using the default animation.
 
 @see scrollToTab:animated:
 */
- (void) scrollToTab: (CALayer *) tab;


/** 
 @brief Scroll the Tab View until tab is fully visibile.
 @param tab A tab contained in the Tab View.
 @param animated Specify YES to animate the transition or NO if you do not want the transition to be animated.
 
 @see scrollToTab:
 */
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


/**
 The SFTabViewDelegate protocol defines the optional methods implemented by delegates of SFTabView objects.
 
 */
@protocol SFTabViewDelegate

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Selecting in the Tab View
//////////////////////////////////////////////////////////////////////////////////////////

@optional
/** 
 @brief Sent to the delegate to allow or prohibit the specified tab to be selected.
 @param tabView The Tab View that sent the message.
 @param tab A tab contained in the Tab View.
 
 When a tab is clicked by the user, this method will be called on the delegate. 
 Returning NO will disallow that tab from being selected. Returning YES allows it to be selected.
 
 @return YES if the tab selection should be allowed, otherwise NO.
 
 @see tabView:didSelectTab:
 @see tabView:willSelectTab:
 */
- (BOOL)tabView:(SFTabView *)tabView shouldSelectTab:(CALayer *)tab;


/** 
 @brief Sent at the time the user clicked a tab in the Tab View.
 @param tabView The Tab View that sent the message.
 @param tab A tab contained in the Tab View.
  
 @see tabView:shouldSelectTab:
 @see tabView:willSelectTab:
 */
- (void)tabView:(SFTabView *)tabView didSelectTab:(CALayer *)tab;

/** 
 @brief Sent at the time the user clicked a tab in the Tab View, just before the tab will change state.
 @param tabView The Tab View that sent the message.
 @param tab A tab contained in the Tab View.
 
 @see tabView:shouldSelectTab:
 @see tabView:didSelectTab:
 */
- (void)tabView:(SFTabView *)tabView willSelectTab:(CALayer *)tab;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Adding and removing tab
//////////////////////////////////////////////////////////////////////////////////////////


/** 
 @brief Sent after a new tab is added to the Tab View.
 @param tabView The Tab View that sent the message.
 @param tab The new tab added to the the Tab View.
 
 @see tabView:didRemovedTab:
 */
- (void)tabView:(SFTabView *)tabView didAddTab:(CALayer *)tab;


/** 
 @brief Sent after a tab is deleted from the Tab View.
 @param tabView The Tab View that sent the message.
 @param tab The tab deleted from the the Tab View.
 
 @see tabView:didAddTab:
 */
- (void)tabView:(SFTabView *)tabView didRemovedTab:(CALayer *)tab;

@end

/**
 The SFTab protocol defines the required methods that the CALayer subclass should implement
 for rendering and behaving as a tab.
 
 */
@protocol SFTab

@required
/** 
 @brief Tabs are are created or modified using the representedObject as model.
 @param representedObject The Object passed to the layer that contain the information for drawing it (title, size, etc...).
 
 The implementation of this method should read the information of the representedObject and build or update the CALayer
 according to it.
 
 */
- (void) setRepresentedObject: (id) representedObject;


/** 
 @brief Toggle the selected state of a tab.
 @param selected If YES the tag is selected.
 
 Usually the tab will change state if selected or not, the implementation should reflect this behaviour.
 
 */
- (void) setSelected: (BOOL) selected;

@end

