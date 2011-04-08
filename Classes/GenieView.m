//
//  GenieView.m
//  genie
//
//  Created by Robert Diamond on 4/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import "GenieView.h"


@implementation GenieView
@synthesize viewRendered;
@synthesize pathRef;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	if (pathRef == nil) {
		[super drawRect:rect];
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextAddPath(ctx, pathRef);
	CGContextClip(ctx);
	CGFloat pos = rectIndex * mySliceHeight;
	
	if (rectIndex) {
		CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
		CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, pos));
	}
	
	for (NSInteger idx = 0; idx < NUM_SLICES && widths[idx] > 0 && pos < self.bounds.size.height; ++idx) {
		CGRect clipBox = CGRectMake(minX[idx+rectIndex], pos, widths[idx+rectIndex], mySliceHeight);
		CGContextSaveGState(ctx);
		CGContextClipToRect(ctx, clipBox);
		
		//NSLog(@"box %@", NSStringFromCGRect(clipBox));
		[[slices objectAtIndex:idx] drawInRect:clipBox];

		CGContextRestoreGState(ctx);
		pos += mySliceHeight;
	}
}

- (void)dealloc {
	CGPathRelease(pathRef);
	[viewRendered release];
	if (_timer) {
		[_timer invalidate];
	}
	[slices release];
    [super dealloc];
}

- (void)setPathRef:(CGPathRef)newRef {
	if (pathRef != nil) {
		CGPathRelease(pathRef);
	}
	pathRef = newRef;
	CGPathRetain(pathRef);
	rectIndex = 0;
	
	// figure out the bounding rects for each of the slices
	CGFloat pos = 0;
	mySliceHeight = floor(self.bounds.size.height / NUM_SLICES);
	
	CGFloat mx;
	int x;
	for (int i=0; i < NUM_SLICES; ++i) {
		for (x=7; x < self.bounds.size.width; ++x) {
			if (CGPathContainsPoint(pathRef, NULL, CGPointMake(x, pos), NO)) {
				minX[i] = x - 7;
				mx = minX[i];
				break;
			}
		}
		if (x == self.bounds.size.width) {
			minX[i] = 0;
			mx = 0;
		}
		for (x=self.bounds.size.width-1; x > mx; --x) {
			if (CGPathContainsPoint(pathRef, NULL, CGPointMake(x, pos), NO)) {
				widths[i] = x - mx + 14;
				break;
			}
		}
		if (x <= mx) {
			widths[i] = 0;
		}
		NSLog(@"pos %f minx %f width %f", pos, minX[i], widths[i]);
		pos += mySliceHeight;
	}
	_timer = [NSTimer scheduledTimerWithTimeInterval:ANIM_TIME_S/NUM_SLICES target:self selector:@selector(drawAgain:) userInfo:nil repeats:YES];
}

- (void)setViewRendered:(UIImage *)img {
	if (slices) {
		[slices release];
		[viewRendered release];
	}
	slices = [[NSMutableArray alloc] initWithCapacity:NUM_SLICES];
	viewRendered = img;
	[viewRendered retain];
	CGImageRef viewCG = img.CGImage;
	CGFloat sliceHeight = floor(viewRendered.size.height / NUM_SLICES);
	//sliceFactor = self.bounds.size.height / viewRendered.size.height;
	mySliceHeight = floor(self.bounds.size.height / NUM_SLICES);
	NSLog(@"image slice height %f my slice height %f", sliceHeight, mySliceHeight);
	CGFloat pos = 0.0f;
	for (int i=0; i < NUM_SLICES; ++i) {
		[slices addObject:[UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewCG, CGRectMake(0, pos, viewRendered.size.width, sliceHeight))
										scale:1.0
								  orientation:UIImageOrientationUp]];
		pos += sliceHeight;
	}
}

- (void)drawAgain:(NSTimer *)timer {
	++rectIndex;
	if (rectIndex == NUM_SLICES) {
		CGPathRelease(pathRef);
		pathRef = nil;
		[timer invalidate];
		_timer = nil;
		if (delegate != nil && [delegate respondsToSelector:@selector(drawingFinished)]) {
			[delegate performSelector:@selector(drawingFinished)];
		}
	} else {
		[self setNeedsDisplay];
	}
}


@end
