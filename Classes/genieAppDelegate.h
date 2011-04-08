//
//  genieAppDelegate.h
//  genie
//
//  Created by Robert Diamond on 4/6/11.
//  Copyright 2011 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@class genieViewController;

@interface genieAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    genieViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet genieViewController *viewController;

@end

