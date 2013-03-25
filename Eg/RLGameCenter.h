//
//  RLGameCenter.h
//  Darken
//
//  Created by Robert Lummis on 11/7/12.
//  Copyright (c) 2012 ElectricTurkey Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define ANNOUNCE NSLog( @"\n|... THREAD: %@\n|... SELF:   %@\n|... METHOD: %@(%d)", \
[NSThread currentThread], self, NSStringFromSelector(_cmd), __LINE__) ;

//#define ANNOUNCE

@interface RLGameCenter : NSObject <GKGameCenterControllerDelegate> {

    NSError *_lastError;
    __block NSArray *serverAchievements;
}

@property (nonatomic, readonly) NSError *lastError;

+(id) singleton;
-(void) authenticateLocalPlayer;
-(void) authenticationChanged;
-(void) setLastError:(NSError *)err;
-(UIViewController *) getRootViewController;
-(void) presentViewController:(UIViewController *)vc;
-(void) submitScore:(int64_t)score category:(NSString *)category;
-(void) submitAchievement:(NSString *)achievementName percentComplete:(double)percentComplete showBanner:(BOOL)showBanner;
//-(void) submitOldAchievements;   //submit achievements that previoiusly failed to submit
-(void) logAchievements;
-(void) resetAchievements;
-(BOOL) os6;    // tests for iOS 6 (YES) or not (if NO assume iOS 5)

@end
