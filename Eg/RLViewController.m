//
//  RLViewController.m
//  Eg
//
//  Created by Robert Lummis on 11/20/12.
//  Copyright (c) 2012 Robert Lummis. All rights reserved.
//

#import "RLViewController.h"
#import "RLGameCenter.h"

NSString *testAchievementName = @"com.electricturkey.darken.test_1";

@interface RLViewController ()

@end

@implementation RLViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    max = 100;
    k = 0;
    pos = 0;
    size = 0.4;
    stepSize.text = [NSString stringWithFormat:@"%5.2f", size];
    [self updateDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [maximum release];
    [currentPosition release];
    [percentComplete release];
    [count release];
    [super dealloc];
}

- (void)viewDidUnload {
    [maximum release];
    maximum = nil;
    [currentPosition release];
    currentPosition = nil;
    [percentComplete release];
    percentComplete = nil;
    [count release];
    count = nil;
    [super viewDidUnload];
}
- (IBAction)doStep {
    pos = ++k * size;
    pos = MIN(pos, max);
    [self updateDisplay];
    [self updateGameCenter];
}

- (IBAction)doReset {
    k = 0;
    pos = 0;
    [self updateDisplay];
    [[RLGameCenter singleton] resetAchievements];
}

- (IBAction)getAchievements {
    [[RLGameCenter singleton] logAchievements];
}

- (IBAction)goToReviewPage {
    NSString *templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=327702034";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:templateReviewURL]];
}

- (void) updateDisplay {
    maximum.text = [NSString stringWithFormat:@"%3d", max];
    count.text = [NSString stringWithFormat:@"%3d", k];
    currentPosition.text = [NSString stringWithFormat:@"%7.2f", pos];
    percentComplete.text = [NSString stringWithFormat:@"%7.2f", pos / max * 100.];
}

-(void) updateGameCenter {
    double pcComplete = (double)pos / max * 100.;
    [[RLGameCenter singleton] submitAchievement:@"com.electricturkey.darken.test_1"
                                percentComplete:pcComplete
                                     showBanner:YES];
}

@end
