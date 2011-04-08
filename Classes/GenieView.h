//
//  GenieView.h
//  genie
//
//  Created by Robert Diamond on 4/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NUM_SLICES 100
#define ANIM_TIME_S .6f

@interface GenieView : UIView {
	NSInteger rectIndex;
	NSTimer *_timer;
	NSMutableArray *slices;
	CGFloat mySliceHeight;
	CGFloat minX[NUM_SLICES];
	CGFloat widths[NUM_SLICES];
}

@property (nonatomic, assign) IBOutlet id<NSObject> delegate;
@property (nonatomic, retain) UIImage *viewRendered;
@property (nonatomic, assign) CGPathRef pathRef;

- (void)drawAgain:(NSTimer *)timer;
@end
