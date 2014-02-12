//
//  ScrollableWorldNode.h
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//#define KelpStartingX 600*DoubleIfIpad

@class JFGameScene;
@interface JFScrollingKelpNode : SKNode
@property (weak, nonatomic) JFGameScene *gameScene;
@property (nonatomic) CGFloat kelpStartingX;
@property (nonatomic) CGFloat kelpSpacing;

+ (void)loadAssets;
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;
@end
