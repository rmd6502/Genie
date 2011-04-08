//
//  genieViewController.h
//  genie
//
//  Created by Robert Diamond on 4/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenieView;
@interface genieViewController : UIViewController {

}

@property (nonatomic,retain) IBOutlet UIView *hideView;
@property (nonatomic,retain) IBOutlet UIButton *hideButton;
@property (nonatomic,retain) IBOutlet UITextField *textField;

- (IBAction)clickButton:(id)sender;
- (void)drawingFinished;

@end

