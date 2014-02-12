//
//  JFGameOverNode.m
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import "JFGameOverNode.h"
#import "JFGameScene.h"
#import "JFUser.h"

@interface JFGameOverNode()

@property (strong, nonatomic) SKLabelNode *restartGameLabel;
@property (strong, nonatomic) SKLabelNode *shareLabel;

@property (nonatomic) BOOL restartingGame;

@end

@implementation JFGameOverNode

-(instancetype)initWithScore:(NSInteger)score {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.zPosition = Z_UI;
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(280*DoubleIfIpad, 300*DoubleIfIpad)];
        bg.alpha = 0.55;
        [self addChild:bg];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        scoreLabel.text = FString(@"score: %d", (int)score);
        scoreLabel.fontColor = UIColorFromRGB(0xf7ed00);
        scoreLabel.fontSize = 18*DoubleIfIpad;
        scoreLabel.position = CGPointMake(0, 120*DoubleIfIpad);
        [self addChild:scoreLabel];
        
        
        SKLabelNode *bestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        bestScoreLabel.fontColor = UIColorFromRGB(0xf7ed00);
        bestScoreLabel.fontSize = 18*DoubleIfIpad;
        bestScoreLabel.position = CGPointMake(0, 80*DoubleIfIpad);
        [self addChild:bestScoreLabel];
        bestScoreLabel.text = FString(@"best: %d", (int)[[JFUser localUser] bestScore]);

        if (score > [[JFUser localUser] bestScore]) {
            SKAction *flash = [SKAction customActionWithDuration:0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                node.hidden = !node.hidden;
            }];
        
            SKAction *blink = [SKAction sequence:@[flash, [SKAction waitForDuration:.5]]];
            [bestScoreLabel runAction:[SKAction repeatActionForever:blink]];
            [[JFUser localUser] setNewScore:score];
            
            
            bestScoreLabel.text = FString(@"new best: %d", (int) score);
        }
    
        
        self.restartGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.restartGameLabel.text = @"Restart";
        self.restartGameLabel.fontSize = 24*DoubleIfIpad;
        self.restartGameLabel.position = CGPointMake(0, -40*DoubleIfIpad);
        [self addChild:self.restartGameLabel];
        
        self.shareLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.shareLabel.text = @"Share";
        self.shareLabel.fontSize = 24*DoubleIfIpad;
        self.shareLabel.position = CGPointMake(0, -120*DoubleIfIpad);
        [self addChild:self.shareLabel];

    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (CGRectContainsPoint(CGRectInset(self.restartGameLabel.frame, -20, -20), location) && !self.restartingGame) {
            NSLog(@"Launch new scene");
            self.restartGameLabel.fontColor = [UIColor blackColor];
            self.restartingGame = YES;
            SKAction *hideSelf = [SKAction moveToY:self.scene.size.height+150 duration:1];
            [self.gameScene clearKelpAndResetGame];
            [self runAction:hideSelf completion:^{
                [self removeFromParent];
            }];
        }
        
        if (CGRectContainsPoint(CGRectInset(self.shareLabel.frame, -20, -20), location) && !self.restartingGame) {
            NSLog(@"share game");
            self.shareLabel.fontColor = [UIColor blackColor];
            NSArray *activities = @[FString(@"Check out Jelly Flap. My high score is %d!\n",(int)[[JFUser localUser] bestScore]), [NSURL URLWithString:@"https://itunes.apple.com/us/app/id817736884"]];
            UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:activities applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList];
            shareVC.excludedActivityTypes = excludeActivities;
            
            [self.scene.view.window.rootViewController presentViewController:shareVC animated:YES completion:^{
                self.shareLabel.fontColor = [UIColor whiteColor];
            }];
        }
    }
}


-(void)animateScores {
    
}
@end
