//
//  JFGameOverNode.h
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class JFGameScene;
@interface JFGameOverNode : SKNode


@property (weak, nonatomic) JFGameScene *gameScene;

-(instancetype)initWithScore:(NSInteger)score;

-(void)animateScores;

@end
