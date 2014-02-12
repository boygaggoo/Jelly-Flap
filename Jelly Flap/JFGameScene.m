//
//  MyScene.m
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import "JFGameScene.h"
#import "JFScrollingKelpNode.h"
#import "JFGameOverNode.h"
#import "JFUser.h"
#import "JFViewController.h"

@interface JFGameScene() <SKPhysicsContactDelegate>
@property (nonatomic) CFTimeInterval lastUpdateTimeInterval;

@property (strong, nonatomic) JFScrollingKelpNode *scrollingKelp;
@property (strong, nonatomic) NSMutableArray *groundNodes;

@property (strong, nonatomic) SKSpriteNode *player;
@property (nonatomic) NSInteger score;
@property (strong, nonatomic) SKLabelNode *scoreLabel;

@property (strong, nonatomic) SKLabelNode *howToPlayNode;
@property (strong, nonatomic) SKLabelNode *rateUsLabel;
@property (strong, nonatomic) SKLabelNode *leaderboardLabel;
@property (strong, nonatomic) SKLabelNode *madeByLabel;
@end

@implementation JFGameScene
//static SKSpriteNode *sSharedDirtNode = nil;
static SKTextureAtlas *sDirtAtlas = nil;
static CGSize dirtTileSize;

+(void)loadAssets {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sDirtAtlas = [SKTextureAtlas atlasNamed:@"Dirt"];
        
//        sSharedDirtNode = [SKSpriteNode spriteNodeWithImageNamed:@"dirt"];
//        sSharedDirtNode.anchorPoint = CGPointMake(0, 0);
//        sSharedDirtNode.zPosition = Z_DIRT;
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathMoveToPoint(path, nil, 0, sSharedDirtNode.size.height-8);
//        CGPathAddLineToPoint(path, nil, sSharedDirtNode.size.width, sSharedDirtNode.size.height-8);
//        sSharedDirtNode.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
//        sSharedDirtNode.physicsBody.categoryBitMask = JFContactCategoriesGround;
        
    });

}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        if (!sDirtAtlas) {
            [JFGameScene loadAssets];
        }
        /* Setup your scene here */
        SKTexture *waterTexutre = [sDirtAtlas textureNamed:@"bg_water"];
        waterTexutre.filteringMode = SKTextureFilteringNearest;
        
        SKSpriteNode *waterBackground = [SKSpriteNode spriteNodeWithTexture:waterTexutre size:size];
        waterBackground.anchorPoint = CGPointMake(0, 0);
        waterBackground.zPosition = Z_WATER;
        [self addChild:waterBackground];

        SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"bubbles" ofType:@"sks"]];
        emitter.zPosition = Z_WATER+1;
        emitter.particleScale *= DoubleIfIpad;
        emitter.particleSpeed *= DoubleIfIpad;
        emitter.particlePositionRange = CGVectorMake(0, size.height);
        emitter.position = CGPointMake(size.width + 10, size.height/2);
        [self addChild:emitter];
        
        self.physicsWorld.gravity = CGVectorMake(0, -4*DoubleIfIpad);
        self.physicsWorld.contactDelegate = self;
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.scoreLabel.fontSize = 38;
        self.scoreLabel.position = CGPointMake(size.width/2, size.height-60);
        [self addChild:self.scoreLabel];

        /* add dirt */
        self.groundHeight = (size.height==480) ? 80 : 140;
        if (IsPad) {
            dirtTileSize = CGSizeMake(128, 128);
            self.groundHeight *= 2;
        } else {
            dirtTileSize = CGSizeMake(64, 64);
        }


        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, self.groundHeight-dirtTileSize.height/2);
        CGPathAddLineToPoint(path, nil, size.width, self.groundHeight-dirtTileSize.height/2);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
        self.physicsBody.categoryBitMask = JFContactCategoriesGround;

        self.groundNodes = [NSMutableArray array];
        [self updateDirtNodes];
        [self updateDirtNodes];
        [self updateDirtNodes];
        [self updateDirtNodes];
        [self updateDirtNodes];
        
        CGFloat labelFontSize = IsPad ? 36 : 18;
        self.howToPlayNode = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.howToPlayNode.position = CGPointMake(size.width/2, size.height/2 - 60*DoubleIfIpad);
        self.howToPlayNode.fontSize = labelFontSize;
        self.howToPlayNode.text = @"Tap to play";
        [self addChild:self.howToPlayNode];
        
        self.rateUsLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.rateUsLabel.position = CGPointMake(size.width * 0.5, size.height/2+120*DoubleIfIpad);
        self.rateUsLabel.fontSize = labelFontSize;
        self.rateUsLabel.text = @"Rate us";
        self.rateUsLabel.alpha = 0;
        [self addChild:self.rateUsLabel];
        
        self.leaderboardLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.leaderboardLabel.position = CGPointMake(size.width * 0.5, size.height/2+120*DoubleIfIpad);
        self.leaderboardLabel.fontSize = labelFontSize;
        self.leaderboardLabel.text = @"Ranking";
        self.leaderboardLabel.alpha = 0;
        [self addChild:self.leaderboardLabel];

        
        self.madeByLabel = [SKLabelNode labelNodeWithFontNamed:@"Press Start 2P"];
        self.madeByLabel.fontSize = IsPad ? 22 : 11;
        self.madeByLabel.position = CGPointMake(size.width*0.5,5*DoubleIfIpad);
        self.madeByLabel.text = @"Credit: Art - Sophie Kirschner";
        self.madeByLabel.alpha = 0;
        [self addChild:self.madeByLabel];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    if (view) {
        [self resetGame];
    }
}

-(void)enablePlayerPhysics {
    self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.player.size.width-(28*DoubleIfIpad), self.player.size.height-(28*DoubleIfIpad))];
    self.player.physicsBody.categoryBitMask = JFContactCategoriesJelly;
    self.player.physicsBody.contactTestBitMask = JFContactCategoriesKelp|JFContactCategoriesGround;
    self.player.physicsBody.collisionBitMask = JFContactCategoriesGround;
    self.player.physicsBody.mass = 0.1;
}

-(void)disablePlayerPhysics {
    self.player.physicsBody = nil;
}

-(void)spawnNewPlayer {
    if (self.player) {
        [self.player removeFromParent];
    }
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Jellyfish"];
    
    CGSize playerSize = IsPad ? CGSizeMake(96, 96) : CGSizeMake(48, 48);
    self.player = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"jelly_1"] size:playerSize];
    self.player.name = @"player";
    self.player.zPosition = Z_PLAYER;
    self.player.position = CGPointMake(80 * (IsPad?2:1), self.size.height/2);
    [self addChild:self.player];
    
    SKAction *animation = [SKAction animateWithTextures:@[[atlas textureNamed:@"jelly_1"], [atlas textureNamed:@"jelly_2"],
                                                          [atlas textureNamed:@"jelly_3"], [atlas textureNamed:@"jelly_4"],
                                                          [atlas textureNamed:@"jelly_5"]] timePerFrame:0.25];
    [self.player runAction:[SKAction repeatActionForever:animation]];
}



-(void)endGame {
    self.currentState = GameStateEnded;
    [self disablePlayerPhysics];
    
    SKAction *shakeRight = [SKAction moveByX:5 y:0 duration:0.1];
    SKAction *shakeLeft = [SKAction moveByX:-5 y:0 duration:0.1];
    
    SKAction *screenShake = [SKAction sequence:@[shakeRight, shakeRight.reversedAction, shakeLeft, shakeLeft.reversedAction]] ;
    
    SKAction *up = [SKAction moveByX:0 y:30 duration:0.3];
    SKAction *down = [SKAction moveToY:self.groundHeight-dirtTileSize.height/2 duration:1];
    SKAction *death = [SKAction sequence:@[up, down]];

    [self runAction:[SKAction repeatAction:screenShake count:2]];
    [self.player removeAllActions];
    [self.player runAction:death completion:^{
        [self removeAllActions];
        JFGameOverNode *gameOverNode = [[JFGameOverNode alloc] initWithScore:self.score];
        gameOverNode.gameScene = self;
        gameOverNode.position = CGPointMake(self.scene.size.width/2, -150);
        [self addChild:gameOverNode];
        [gameOverNode runAction:[SKAction moveToY:self.scene.size.height/2 duration:0.6]];
        
        [self.player runAction:[SKAction fadeAlphaTo:0 duration:5]];
        
    }];
    
    [self.madeByLabel runAction:[SKAction fadeAlphaTo:1 duration:0.3]];
    SKAction *scrollText = [SKAction moveToX:-300*DoubleIfIpad duration:20];
    SKAction *resetText = [SKAction moveToX:self.size.width+(300*DoubleIfIpad) duration:0];
    SKAction *sequence = [SKAction sequence:@[resetText, scrollText]];
    [self.madeByLabel runAction:[SKAction repeatActionForever:sequence]];

}


-(void)clearKelpAndResetGame {
    [self.scrollingKelp runAction:[SKAction fadeAlphaTo:0 duration:1] completion:^{
        [self.scrollingKelp removeFromParent];
        [self resetGame];
    }];
}

-(void)resetGame {
    self.score = 0;
    self.scoreLabel.text = @"0";

    
    [self.scrollingKelp removeFromParent];
    
    self.scrollingKelp = [JFScrollingKelpNode node];
    self.scrollingKelp.gameScene = self;
    [self addChild:self.scrollingKelp];


    [self.madeByLabel runAction:[SKAction fadeAlphaTo:0 duration:0.3]];

    
    [self spawnNewPlayer];
    self.player.alpha = 0;
    [self.player runAction:[SKAction fadeAlphaTo:1 duration:1]];

    self.currentState = GameStateNew;

    self.howToPlayNode.hidden = NO;
    self.howToPlayNode.alpha = 1;
    
    
    JFUser *user = [JFUser localUser];
    if (user.isGameCenterEnabled && !user.isAuthenticated && user.authenticationViewController) {
        NSLog(@"present GC login");
        [self.view.window.rootViewController presentViewController:user.authenticationViewController animated:YES completion:nil];
        user.authenticationViewController= nil;
    }
    
    
    if (user.bestScore > 1 && !user.hasRatedApp) {
        [self.rateUsLabel runAction:[SKAction fadeAlphaTo:1 duration:1]];
        
    } else if (user.isAuthenticated) {
        [self.leaderboardLabel runAction:[SKAction fadeAlphaTo:1 duration:1]];

    }
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (self.currentState == GameStateNew) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            
            if (self.rateUsLabel.alpha == 1 && CGRectContainsPoint(CGRectInset(self.rateUsLabel.frame, -20, -20), location)) {
                NSLog(@"RATE US");
                
                static NSString *const url = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=817736884";
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                [JFUser localUser].hasRatedApp = YES;
                return;
            }
            
            if (self.leaderboardLabel.alpha == 1 && CGRectContainsPoint(CGRectInset(self.leaderboardLabel.frame, -20, -20), location)) {
                NSLog(@"LEADERBOARD");
                GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
                if (gameCenterController != nil)
                {
                    gameCenterController.gameCenterDelegate = self.parentViewController;
                    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
                    [self.parentViewController presentViewController: gameCenterController animated: YES completion:nil];
                }
                return;
            }
        }

        [self.rateUsLabel removeAllActions];
        [self.leaderboardLabel removeAllActions];
        
        [self.howToPlayNode runAction:[SKAction fadeAlphaTo:0 duration:0.3]];
        [self.rateUsLabel runAction:[SKAction fadeAlphaTo:0 duration:0.3]];
        [self.leaderboardLabel runAction:[SKAction fadeAlphaTo:0 duration:0.3]];
        
        self.currentState = GameStateRunning;
        [self enablePlayerPhysics];
    }

    if (self.currentState == GameStateRunning) {
        if (self.player.position.y < self.scene.size.height-30) {
            self.player.physicsBody.velocity = CGVectorMake(0, 0);
            [self.player.physicsBody applyImpulse:CGVectorMake(0, 25*DoubleIfIpad)];
        }
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    if (self.currentState == GameStateRunning) {
        [self.scrollingKelp updateWithTimeSinceLastUpdate:timeSinceLast];
        
        CGPoint offset = [self.scene convertPoint:self.player.position toNode:self.scrollingKelp];

        int numberOfKelpPassed = (int) ((offset.x-self.scrollingKelp.kelpStartingX+self.player.size.width/2)/(self.scrollingKelp.kelpSpacing) + 1);
                
        if (numberOfKelpPassed > 0) {
            self.scoreLabel.text = [NSString stringWithFormat:@"%d", numberOfKelpPassed];
            self.score = numberOfKelpPassed;
        }
    }
    
    if (self.currentState != GameStateEnded) {
        for (SKSpriteNode *dirt in self.groundNodes) {
            dirt.position = CGPointMake(dirt.position.x - (SCROLL_SPEED*timeSinceLast*DoubleIfIpad), dirt.position.y);
        }
        [self updateDirtNodes];
    }
    
    
}


-(SKTexture *)randomDirtTopTexture {
    SKTexture *tx = [sDirtAtlas textureNamed:FString(@"dirt_top_%d", arc4random_uniform(4)+1)];
    tx.filteringMode = SKTextureFilteringNearest;
    return tx;
}
-(SKTexture *)randomDirtMidTexture {
    SKTexture *tx = [sDirtAtlas textureNamed:FString(@"dirt_mid_%d", arc4random_uniform(8)+1)];
    tx.filteringMode = SKTextureFilteringNearest;
    return tx;
}


-(SKSpriteNode *)randomDirtNode {
    SKSpriteNode *topDirt = [SKSpriteNode spriteNodeWithTexture:[self randomDirtTopTexture] size:dirtTileSize];
    topDirt.anchorPoint = CGPointMake(0.5, 1);
    topDirt.zPosition = Z_DIRT;
    for (int i = 1; i < 4; i++) {
        SKSpriteNode *midDirt = [SKSpriteNode spriteNodeWithTexture:[self randomDirtMidTexture] size:dirtTileSize];
        midDirt.anchorPoint = CGPointMake(0.5, 1);
        midDirt.position = CGPointMake(0, -(dirtTileSize.height * i));
        midDirt.zPosition = Z_DIRT;
        [topDirt addChild:midDirt];
    }
    
    return topDirt;
}

-(void)updateDirtNodes {
    
    SKSpriteNode *lastNode = [self.groundNodes lastObject];
    if (!lastNode) {
        SKSpriteNode *newDirtNode = [self randomDirtNode];
        newDirtNode.position = CGPointMake(0, self.groundHeight);
        [self addChild:newDirtNode];
        [self.groundNodes addObject:newDirtNode];
    } else {
        CGFloat farRight = [self.scene convertPoint:lastNode.position fromNode:lastNode.parent].x;
        if (farRight < self.scene.size.width * 2) {
            SKSpriteNode *newDirtNode = [self randomDirtNode];
            newDirtNode.position = CGPointMake(lastNode.position.x + lastNode.size.width, self.groundHeight);
            [self addChild:newDirtNode];
            [self.groundNodes addObject:newDirtNode];
        }
    }
    
    SKSpriteNode *firstNode = [self.groundNodes firstObject];
    CGFloat farLeft = [self.scene convertPoint:firstNode.position fromNode:firstNode.parent].x;
    
    if (farLeft < -firstNode.size.width*2) {
        
        [firstNode removeFromParent];
        [self.groundNodes removeObject:firstNode];
    }
    
}




-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *node = contact.bodyA.node;
    if ([node.name isEqualToString:@"player"]) {
        [self endGame];
    }
    
    // Check bodyB too.
    node = contact.bodyB.node;
    if ([node.name isEqualToString:@"player"]) {
        [self endGame];
    }
}
@end
