//
//  SFDefaultTab.m
//  tabtest
//
//  Created by Matteo Rattotti on 2/28/10.
//  Copyright 2010 www.shinyfrog.net. All rights reserved.
//

#import "SFDefaultTab.h"

static CGImageRef  activeTab;
static CGImageRef  inactiveTab;


@implementation SFLabelLayer
- (BOOL)containsPoint:(CGPoint)p
{
	return FALSE;
}
@end

@implementation SFDefaultTab

- (void) setRepresentedObject: (id) representedObject {
	CAConstraintLayoutManager *layout = [CAConstraintLayoutManager layoutManager];
    [self setLayoutManager:layout];

    _representedObject = representedObject;
    self.frame = CGRectMake(0, 0, 120, 30);
        //NSLog(@"asd -> %@", [[NSBundle mainBundle] pathForResource:@"tabActive" ofType:@"png"]);
        if(!activeTab) {
            CFStringRef path = (CFStringRef)[[NSBundle mainBundle] pathForResource:@"activeTab" ofType:@"png"];
            CFURLRef imageURL = CFURLCreateWithFileSystemPath(nil, path, kCFURLPOSIXPathStyle, NO);
            CGImageSourceRef imageSource = CGImageSourceCreateWithURL(imageURL, nil);
            activeTab = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
                         CFRelease(imageURL); CFRelease(imageSource);

            
             path = (CFStringRef)[[NSBundle mainBundle] pathForResource:@"inactiveTab" ofType:@"png"];
             imageURL = CFURLCreateWithFileSystemPath(nil, path, kCFURLPOSIXPathStyle, NO);
             imageSource = CGImageSourceCreateWithURL(imageURL, nil);
            inactiveTab = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
             CFRelease(imageURL); CFRelease(imageSource);

        }
        [self setContents: (id)inactiveTab];

    SFLabelLayer *tabLabel = [SFLabelLayer layer];
	if ([representedObject objectForKey:@"name"] != nil) {
		tabLabel.string = [representedObject objectForKey:@"name"];

	}
	[tabLabel setFontSize:13.0f];
	[tabLabel setShadowOpacity:.9f];
	tabLabel.shadowOffset = CGSizeMake(0, -1);
	tabLabel.shadowRadius = 1.0f;
	tabLabel.shadowColor = CGColorCreateGenericRGB(1,1,1, 1);
	tabLabel.foregroundColor = CGColorCreateGenericRGB(0.1,0.1,0.1, 1);
	tabLabel.truncationMode = kCATruncationEnd;
	tabLabel.alignmentMode = kCAAlignmentCenter;
	CAConstraint *constraint = [CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                          relativeTo:@"superlayer"
                                                           attribute:kCAConstraintMidX];    
    [tabLabel addConstraint:constraint];
    
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMidY
                                            relativeTo:@"superlayer"
                                             attribute:kCAConstraintMidY
												offset:-4.0];
    [tabLabel addConstraint:constraint];

	constraint = [CAConstraint constraintWithAttribute:kCAConstraintMaxX
                                            relativeTo:@"superlayer"
                                             attribute:kCAConstraintMaxX
												offset:-20.0];
    [tabLabel addConstraint:constraint];

	constraint = [CAConstraint constraintWithAttribute:kCAConstraintMinX
                                            relativeTo:@"superlayer"
                                             attribute:kCAConstraintMinX
												offset:20.0];
    [tabLabel addConstraint:constraint];
	
	
	[tabLabel setFont:@"LucidaGrande"];
	
	[self addSublayer:tabLabel];

    

    //self.borderColor = CGColorCreateGenericRGB(0,0,0, 1);
    //self.borderWidth = 1.0;
	//self.backgroundColor = CGColorCreateGenericRGB(0,0,0, 1);
}


- (void) setSelected: (BOOL) selected {
    [CATransaction begin]; 
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];

    if (selected)
        [self setContents: (id)activeTab];
    else
        [self setContents: (id)inactiveTab];
    
    [CATransaction commit];

}

@end
