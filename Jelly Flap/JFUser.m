//
//  JFUser.m
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import "JFUser.h"

//NSString *const kUserScoreDefaults = @"jellyflap.UserScore";
NSString *const kDefaultsBestScore = @"defaults.BestScore";

@interface JFUser ()
@property (nonatomic, weak) GKLeaderboard *defaultLeaderboard;
@property (nonatomic, weak) GKLocalPlayer *localPlayer;
@end
@implementation JFUser
+(instancetype)localUser {
    static id user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [JFUser new];
    });
    return user;
}

-(id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _hasRatedApp = [defaults boolForKey:@"defaults.HasRatedApp"];
        
        [self authenticateLocalPlayer];
        
    }
    return self;
}

-(void)setHasRatedApp:(BOOL)hasRatedApp {
    _hasRatedApp = hasRatedApp;
    [[NSUserDefaults standardUserDefaults] setBool:hasRatedApp forKey:@"defaults.HasRatedApp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) authenticateLocalPlayer
{
    self.localPlayer = [GKLocalPlayer localPlayer];
    self.localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){

        if (viewController != nil)
        {
            _isGameCenterEnabled = YES;

            self.authenticationViewController = viewController;
        }
        else if (self.localPlayer.isAuthenticated)
        {
            _isGameCenterEnabled = YES;

            _isAuthenticated = YES;
            NSLog(@"user Authenticated");
            [self loadLeaderboard];

        }
        else
        {
            NSLog(@"not authenticated");
            _isGameCenterEnabled = NO;
        }
    };
}
-(void)loadLeaderboard {
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        self.defaultLeaderboard = [leaderboards firstObject];
    }];
}

-(void)showLeaderboard {
   
    
}

-(void)setNewScore:(NSInteger)score {
    NSInteger bestScore = [self bestScore];
    if (score > bestScore) {
       
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"net.domenicali.JellyFlap.HighScore"];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        NSArray *scores = @[scoreReporter];
        
        [GKScore reportScores:scores withCompletionHandler:nil];

        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:kDefaultsBestScore];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSInteger)bestScore {
    if (self.defaultLeaderboard) {
        return (int) MIN(9999, [self.defaultLeaderboard localPlayerScore].value);
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:kDefaultsBestScore];
}
@end
