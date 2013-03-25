//
//  RLGameCenter.m
//  Darken
//
//  Created by Robert Lummis on 11/7/12.
//  Copyright (c) 2012 ElectricTurkey Software. All rights reserved.
//

#import "RLGameCenter.h"

@implementation RLGameCenter

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -  Singleton stuff

+(id) singleton {
    static RLGameCenter *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[RLGameCenter alloc] init];
    });
    return singleton;
}

-(id) init {
    ANNOUNCE
    if ( ( self = [super init] ) ) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(authenticationChanged)
                   name:GKPlayerAuthenticationDidChangeNotificationName
                 object:nil];
    }
    return self;
}

#pragma mark - Authenticate Local Player

-(void) authenticateLocalPlayer {
    ANNOUNCE
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    _lastError = nil;
    
            //iOS 6
    if ( [self os6] ) {
        localPlayer.authenticateHandler = ^(UIViewController *loginVC, NSError *error) {
            NSLog(@"in authenticateHandler 1");
            [self setLastError:error];
                //... resume application responses
//            [[CCDirector sharedDirector] resume];   //if not paused does nothing 
            if ( [GKLocalPlayer localPlayer].authenticated) {
                NSLog(@"in authenticateHandler 2 - local player is authenticated");
                    //            _gameCenterFeaturesEnabled = YES;
            } else if (loginVC) {
                NSLog(@"in authenticateHandler 3 - local player is not authenticated, will present VC");
                    //... pause applications responses
//                [[CCDirector sharedDirector] pause];
                [self presentViewController:loginVC];
            } else {
                NSLog(@"in authenticateHandler 4 - local player is NOT authenticated, no VC returned");
                    //            _gameCenterFeaturesEnabled = NO;
            }
            NSLog(@"authenticateHandler error: %@", error.localizedDescription);
        };
        
            //iOS 5
    } else {
        if ( [GKLocalPlayer localPlayer].authenticated == NO ) {
                //no completion handler because we're relying on NSNotificationCenter
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
            NSLog(@"local player authentication requested");
        } else {
            NSLog(@"local player was already authenticated");
        }
        
    }
}

-(void) authenticationChanged {
    ANNOUNCE
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ( [GKLocalPlayer localPlayer].authenticated ) {
            NSLog(@"authenticationChanged: player is authenticated");
            
        } else if (!!! [GKLocalPlayer localPlayer].isAuthenticated && [GKLocalPlayer localPlayer].authenticated) {
            NSLog(@"authenticationChanged: now player is not authenticated");
        } else {
            NSLog(@"authenticationChanged: player was not authenticated and is still not authenticated");
        }
    });
}

#pragma mark - Error

-(void) setLastError:(NSError *)error {
    ANNOUNCE
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"RLGameCenter Error: %@", _lastError.localizedDescription);  //add alert box here
    }
    [_lastError release];
}

#pragma mark - ViewController stuff

#pragma mark UIViewController stuff
-(UIViewController *) getRootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController *)vc {
    UIViewController *rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES completion:nil];
}

#pragma mark - submit to game center

-(void) submitScore:(int64_t)score category:(NSString *)leaderboardIdentifier {
    ANNOUNCE
    if (!!! [GKLocalPlayer localPlayer].authenticated ) {
        NSLog(@"GKLocalPlayer is not authenticated");
        return;
    }
    
    GKScore *gkScore = [[GKScore alloc] initWithCategory:leaderboardIdentifier];
    gkScore.value = score;
    [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
        [self setLastError:error];
    }];
}

-(void) submitAchievement:(NSString *)achievementName percentComplete:(double)percentComplete showBanner:(BOOL)showBanner {
    ANNOUNCE
    NSLog(@"reporting achievement:%@, percentComplete:%g, banner:%d", achievementName, percentComplete, showBanner);
    if ( !!! [GKLocalPlayer localPlayer].authenticated ) {
        NSLog(@"can't submit achievement because GKLocalPlayer is not authenticated");
        return;
    }
    NSAssert(percentComplete >= 0.0 && percentComplete <= 100.0, @"percentComplete not in range 0. - 100.");
    
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:achievementName] autorelease];
    achievement.showsCompletionBanner = showBanner;
    achievement.percentComplete = percentComplete;
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error) {
            NSLog(@"loadAchievementsWithCompletionHandler error: %@. Achievement not reported.", error.localizedDescription);
            return;
        }
        NSLog(@"loadAchievementsWithCompletionHandler [achievements count]: %d", [achievements count]);
        for (GKAchievement *ach in achievements) {
            if ( [ach.identifier isEqualToString:achievementName] && ach.completed) {
                NSLog(@"achievement already completed: %@ so don't submit", achievementName);
                return;
            }
        }
            //if we get here the achievement was not already submitted & the localPlayer is authenticated
        NSString *blockAchievementName = [achievementName copy];    //can't use method arg in block ?
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"reportAchievement failed. name: %@, error: %@", blockAchievementName, error.localizedDescription );
            } else {
                NSLog(@"achievement: %@ reported successfully with percent complete: %f.", blockAchievementName, achievement.percentComplete);
            }
            [blockAchievementName release];
        }];
    }];
}

-(void) logAchievements {
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error) {
            NSLog(@"loadAchievementsWithCompletionHandler error: %@. Achievement not reported.", error.localizedDescription);
            return;
        }
        else {
            NSLog(@"loadAchievementsWithCompletionHandler returned %d achievements:", [achievements count]);
            for (GKAchievement *ach in achievements) {
                NSLog(@"achievement name: %@, percent complete: %f", ach.identifier, ach.percentComplete);
            }
        }
    }];
}

        //not good as is - we aren't dealing with the possibility of no response or other error
        //also I think this has to have main thread stuff
-(void) resetAchievements {
    ANNOUNCE
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"failed to reset achievements. error: %@", error.localizedDescription );
        } else {
            NSLog(@"achievements reset");
        }
    }];
}

#pragma mark - GKGameCenterControllerDelegate required method

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
        //GKLocalPlayer class reference says the game center VC is dismissed automatically
    ANNOUNCE
        //... resume application responses
}


-(BOOL) os6 {
    ANNOUNCE
    NSString *targetSystemVersion = @"6.0";
    NSString *currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if ([currentSystemVersion compare:targetSystemVersion options:NSNumericSearch] == NSOrderedAscending) {
        return NO;  //current system version is less than 6.0
    } else {
        return YES;
    }
}

@end
