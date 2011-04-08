//
//  genieViewController.m
//  genie
//
//  Created by Robert Diamond on 4/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "genieViewController.h"
#import "GenieView.h"

@implementation genieViewController
@synthesize hideView;
@synthesize hideButton;
@synthesize textField;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] != 1) return;
	if (((UITouch *)[touches anyObject]).view != textField) {
		[textField resignFirstResponder];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.hideView = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (IBAction)clickButton:(id)sender {
	// disable the button
	[sender setEnabled:NO];
	
	// render the view to an offline context
	CGColorSpaceRef csp = CGColorSpaceCreateDeviceRGB();
	if (csp == NULL) {
		[sender setEnabled:YES];
		return;
	}
	CGContextRef bmc = CGBitmapContextCreate(NULL, hideView.bounds.size.width, hideView.bounds.size.height, 
											 8, hideView.bounds.size.width * 4, csp, kCGImageAlphaPremultipliedLast);
	if (bmc == NULL) {
		CGColorSpaceRelease(csp);
		[sender setEnabled:YES];
		return;
	}
	
	CGContextTranslateCTM(bmc, 0, hideView.bounds.size.height);
	CGContextScaleCTM(bmc, 1, -1);
	[hideView.layer renderInContext:bmc];
	
	CGImageRef renderref = CGBitmapContextCreateImage(bmc);
	UIImage *render = [UIImage imageWithCGImage:renderref scale:1.0 orientation:UIImageOrientationDownMirrored];
	
	((GenieView *)self.view).viewRendered = render;
	CGImageRelease(renderref);
	
	CGContextRelease(bmc);
	CGColorSpaceRelease(csp);
	
	// calculate the bezier path
	CGMutablePathRef pathRef = CGPathCreateMutable();
	CGPathMoveToPoint(pathRef, NULL, 0, 0);
	CGPathAddCurveToPoint(pathRef, NULL, hideButton.frame.origin.x/3, hideView.bounds.size.height* 2/3, hideButton.frame.origin.x* 2/3, hideView.bounds.size.height/3, hideButton.frame.origin.x, hideButton.frame.origin.y);
	CGPathAddLineToPoint(pathRef, NULL, hideButton.frame.origin.x + hideButton.frame.size.width, hideButton.frame.origin.y);
	CGPathAddCurveToPoint(pathRef, NULL, hideView.frame.size.width* 2/3, hideView.bounds.size.height/3, hideButton.frame.size.width, hideView.bounds.size.height* 2/3, hideView.bounds.size.width, 0);
	CGPathCloseSubpath(pathRef);
	
	((GenieView *)self.view).pathRef = pathRef;
	CGPathRelease(pathRef);

	// start the draw process
	CATransition *trans = [[CATransition alloc]init];
	trans.duration = .25;
	trans.type = kCATransitionFade;
	[self.hideView.layer addAnimation:trans forKey:@"fade"];
	[trans release];
	self.hideView.hidden = YES;
}

- (void)drawingFinished {
	hideButton.enabled = YES;
	hideView.hidden = NO;
}
@end
