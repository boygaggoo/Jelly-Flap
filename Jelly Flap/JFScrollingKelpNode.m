//
//  ScrollableWorldNode.m
//  Jelly Flap
//
//  Created by Nick Domenicali on 2/9/14.
//  Copyright (c) 2014 Nick Domenicali. All rights reserved.
//

#import "JFScrollingKelpNode.h"
#import "JFGameScene.h"

@interface JFScrollingKelpNode ()

@property (strong, nonatomic) NSMutableArray *kelpNodes;

@end

@implementation JFScrollingKelpNode

//static SKNode *sSharedKelpNode = nil;
//static NSArray *sKelpTextureTops = nil;
//static NSArray *sKelpTextureMids = nil;
//static NSArray *sKelpTextureBottoms = nil;
static SKTextureAtlas *sKelpAtlas = nil;

static CGSize kelpSize;
static CGFloat gapDistance;
+(void)loadAssets {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IsPad) {
            kelpSize = CGSizeMake(128, 128);
            gapDistance = 128 * 2;

        } else {
            kelpSize = CGSizeMake(64, 64);
            gapDistance = 128;
        }
        sKelpAtlas = [SKTextureAtlas atlasNamed:@"Kelp"];
        
    });
}

-(SKTexture *)randomBottomTexture {
    SKTexture *tx = [sKelpAtlas textureNamed:FString(@"kelp_bottom_%d", arc4random_uniform(4)+1)];

    tx.filteringMode = SKTextureFilteringNearest;
    return tx;
}

-(SKTexture *)randomTopTexture {
    SKTexture *tx = [sKelpAtlas textureNamed:FString(@"kelp_top_%d", arc4random_uniform(4)+1)];
    tx.filteringMode = SKTextureFilteringNearest;
    return tx;
}

-(SKTexture *)randomMidTexture {
    SKTexture *tx = [sKelpAtlas textureNamed:FString(@"kelp_mid_%d", arc4random_uniform(4)+1)];
    tx.filteringMode = SKTextureFilteringNearest;
    return tx;
}

-(id)init {
    if (self = [super init]) {
        if (!sKelpAtlas) {
            [JFScrollingKelpNode loadAssets];
        }
        self.kelpSpacing = 200 * DoubleIfIpad;
        self.kelpStartingX = 600 * DoubleIfIpad;
        self.kelpNodes = [NSMutableArray array];
    }
    return self;
}


-(SKNode *)createRandomKelpNode {
    SKNode *kelpNode = [SKNode node];
    kelpNode.zPosition = Z_KELP;
    float pipeHeight = kelpSize.height * 10;
    
    
    /* create bottom kelp */

    SKSpriteNode *b1 = [SKSpriteNode spriteNodeWithTexture:[self randomBottomTexture] size:kelpSize];
    b1.zPosition = Z_KELP;
    b1.anchorPoint = CGPointMake(0.5, 1);
    b1.position = CGPointMake(0, -gapDistance/2);
    [kelpNode addChild:b1];
    float bottomY = b1.position.y - b1.size.height;
    for (int i = 0; i < 5; i++) {
        SKSpriteNode *mid = [SKSpriteNode spriteNodeWithTexture:[self randomMidTexture] size:kelpSize];
        mid.zPosition = Z_KELP;
        mid.anchorPoint = CGPointMake(0.5, 1);
        mid.position = CGPointMake(0, bottomY);
        [kelpNode addChild:mid];
        bottomY -= mid.size.height;
    }
    
    
    /* create top kelp */
    
    SKSpriteNode *t1 = [SKSpriteNode spriteNodeWithTexture:[self randomTopTexture] size:kelpSize];
    t1.zPosition = Z_KELP;
    t1.anchorPoint = CGPointMake(0.5, 0);
    t1.position = CGPointMake(0, gapDistance/2);
    [kelpNode addChild:t1];
    float topY = t1.position.y + t1.size.height;
    for (int i = 0; i < 5; i++) {
        SKSpriteNode *mid = [SKSpriteNode spriteNodeWithTexture:[self randomMidTexture] size:kelpSize];
        mid.zPosition = Z_KELP;
        mid.anchorPoint = CGPointMake(0.5, 0);
        mid.position = CGPointMake(0, topY);
        [kelpNode addChild:mid];
        topY += mid.size.height;
    }
    
    
    SKNode *bottomBody = [SKNode node];
    CGPathRef bottomPath = CGPathCreateWithRect(CGRectMake(-kelpSize.width/2, -pipeHeight/2, kelpSize.width, pipeHeight/2 - gapDistance/2), nil);
    bottomBody.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:bottomPath];
    bottomBody.physicsBody.categoryBitMask = JFContactCategoriesKelp;
    
    
    SKNode *topBody = [SKNode node];
    CGPathRef topPath = CGPathCreateWithRect(CGRectMake(-kelpSize.width/2, gapDistance/2, kelpSize.width, pipeHeight/2 - gapDistance/2), nil);
    topBody.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:topPath];
    topBody.physicsBody.categoryBitMask = JFContactCategoriesKelp;
    
    
    [kelpNode addChild:bottomBody];
    [kelpNode addChild:topBody];

    
    
    return kelpNode;
}

-(void)plantKelp {
    
    SKNode *lastKelp = [self.kelpNodes lastObject];
    CGFloat yOffset = self.gameScene.groundHeight+kelpSize.height;
    
    CGFloat yRandomInterval = IsPad ? 420 : 250;
    
    if (!lastKelp) {
        SKNode *kelp = [self createRandomKelpNode];
        kelp.position = CGPointMake(self.kelpStartingX, arc4random_uniform(yRandomInterval) + yOffset);
//        kelp.position = CGPointMake(KelpStartingX * DoubleIfIpad, yOffset);
        [self addChild:kelp];
        [self.kelpNodes addObject:kelp];

    } else
    
    if (lastKelp.position.x <= abs(self.position.x) + self.kelpSpacing) {
        SKNode *kelp = [self createRandomKelpNode];
        kelp.position = CGPointMake(lastKelp.position.x + self.kelpSpacing, arc4random_uniform(yRandomInterval) + yOffset);
//        kelp.position = CGPointMake(lastKelp.position.x + xSpacing, yRandomInterval + yOffset);
        
        [self addChild:kelp];
        [self.kelpNodes addObject:kelp];
        
    }
    
    
    
    SKNode *firstNode = [self.kelpNodes firstObject];
    CGFloat farLeft = [self.scene convertPoint:firstNode.position fromNode:firstNode.parent].x;
    
    if (farLeft < - self.kelpSpacing) {
        
        [firstNode removeFromParent];
        [self.kelpNodes removeObject:firstNode];
    }

    
    
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    self.position = CGPointMake(self.position.x - (SCROLL_SPEED*interval*DoubleIfIpad), self.position.y);

    [self plantKelp];
//    [self updateDirtNodes];
}


@end
