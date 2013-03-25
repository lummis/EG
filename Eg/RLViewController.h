//
//  RLViewController.h
//  Eg
//
//  Created by Robert Lummis on 11/20/12.
//  Copyright (c) 2012 Robert Lummis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLViewController : UIViewController  {

    int max;
    int k;
    float pos;
    float size;
    
    IBOutlet UILabel *maximum;
    IBOutlet UILabel *currentPosition;
    IBOutlet UILabel *percentComplete;
    IBOutlet UILabel *stepSize;
    IBOutlet UILabel *count;
    
}

- (IBAction)doStep;
- (IBAction)doReset;
- (IBAction)getAchievements;

- (IBAction)goToReviewPage;

@end
