//
//  MyScene.h
//  Jelly Flap
//

//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(uint32_t, JFContactCategories) {
    JFContactCategoriesGround   = 0x1 << 0,
    JFContactCategoriesKelp     = 0x1 << 1,
    JFContactCategoriesJelly    = 0x1 << 2
};

typedef NS_ENUM(NSInteger, GameState) {
    GameStateNew,
    GameStateRunning,
    GameStateEnded
};

#define SCROLL_SPEED 120.0

#define Z_WATER     -99
#define Z_KELP      -10
#define Z_DIRT      -5
#define Z_PLAYER    10
#define Z_UI        20

@class JFViewController;
@interface JFGameScene : SKScene
@property (weak, nonatomic) JFViewController *parentViewController;
@property (nonatomic) GameState currentState;
@property (nonatomic) CGFloat groundHeight;

-(void)resetGame;
-(void)clearKelpAndResetGame;
+(void)loadAssets;
@end
