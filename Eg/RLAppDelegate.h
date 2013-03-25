//
//  RLAppDelegate.h
//  Eg
//
//  Created by Robert Lummis on 11/20/12.
//  Copyright (c) 2012 Robert Lummis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RLViewController;

@interface RLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RLViewController *viewController;

@end
