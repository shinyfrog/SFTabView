//
//  SFTabViewAppDelegate.m
//  SFTabView
//
//  Created by Matteo Rattotti on 5/10/10.
//  Copyright 2010 Shiny Frog. All rights reserved.
//

#import "SFTabViewAppDelegate.h"

@implementation SFTabViewAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	tabView.delegate = self;
    tabView.tabOffset = -20;
    tabView.startingOffset = 20;
	
    [tabView addTabWithRepresentedObject:[NSDictionary dictionaryWithObject:@"One" forKey:@"name"]];
    
	number = 1;
}

- (void) removeTab: (id) sender {
	--number;
	
	[tabView removeTab:[tabView selectedTab]];
}

- (void) addTab: (id) sender {
	++number;
	[tabView addTabWithRepresentedObject:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", number] forKey:@"name"]];
	[tabView selectTab:[tabView lastTab]];
}

- (void)tabView:(SFTabView *)tabView didAddTab:(CALayer *)tab {
}

- (void)tabView:(SFTabView *)tabView didRemovedTab:(CALayer *)tab {
}

- (BOOL)tabView:(SFTabView *)tabView shouldSelectTab:(CALayer *)tab {
    return YES;
}

- (void)tabView:(SFTabView *)tabView didSelectTab:(CALayer *)tab {
}

- (void)tabView:(SFTabView *)tabView willSelectTab:(CALayer *)tab {
}
@end
