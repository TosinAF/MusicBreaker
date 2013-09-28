//
//  MBMyScene.m
//  MusicBreaker
//
//  Created by Tosin Afolabi on 28/09/2013.
//  Copyright (c) 2013 Tosin Afolabi. All rights reserved.
//

#define SPECIAL_MODE NO
#define BRICK_VERTICAL_PADDING 35
#define BRICK_HORIZONTAL_PADDING 60
#define BRICK_DISPLAY_STARTING_POINT CGPointMake(38, 240)
#define BACKGROUND_COLOR [SKColor colorWithRed:0.937 green:0.953 blue:0.953 alpha:1]

#import "MBMyScene.h"

static const uint32_t ballCategory   = 0x1 << 0;
static const uint32_t brickCategory  = 0x1 << 1;
static const uint32_t paddleCategory = 0x1 << 2;

@interface MBMyScene ()

@property (nonatomic, assign) CGSize windowSize;
@property (nonatomic, strong) SKSpriteNode *paddle;
@property (nonatomic, strong) SKSpriteNode *ball;

@end

@implementation MBMyScene

-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {

        self.windowSize = size;
        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = BACKGROUND_COLOR;
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        /* Set Up Sprites */
        [self displayAndArrangeBricks];
        [self displayPaddle];
        [self displayBall];

    }

    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPaddle:)];
    [self.view addGestureRecognizer:panGesture];

}

- (void)didSimulatePhysics {

}

#pragma mark - Sprite Creation Methods

- (void)displayAndArrangeBricks {

    int i,j = 0;
    CGPoint brickPosition = BRICK_DISPLAY_STARTING_POINT;
    NSArray *brickImages = [[NSArray alloc] initWithObjects:@"RedBrick", @"YellowBrick", @"GreenBrick", @"BlueBrick", @"PurpleBrick",nil];

    for ( i = 0 ; i < 5 ; i++) {

        NSUInteger columnLength = (arc4random() % 5) + 3;

        for ( j = 0 ; j < columnLength ; j++ ) {

            SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:brickImages[arc4random() % 5]];
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.size];
            brick.physicsBody.dynamic = NO;
            brick.physicsBody.categoryBitMask = brickCategory;
            //brick.physicsBody.contactTestBitMask = ballCategory;
            brick.position = brickPosition;

            [self addChild:brick];

            brickPosition.y += BRICK_VERTICAL_PADDING;
        }

        brickPosition.x += BRICK_HORIZONTAL_PADDING;
        brickPosition.y = BRICK_DISPLAY_STARTING_POINT.y;

    }
}

- (void)displayPaddle {

    CGPoint windowCenter = CGPointMake(self.windowSize.width / 2, self.windowSize.height / 2);

    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle"];
    self.paddle.position = CGPointMake(windowCenter.x, windowCenter.y - 175);
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.size];
    self.paddle.physicsBody.dynamic = NO;
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    self.paddle.physicsBody.contactTestBitMask = ballCategory;

    [self addChild:self.paddle];
}

- (void)displayBall {

    self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"Ball"];
    self.ball.position = CGPointMake(15, 0);
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.size.width / 2];
    self.ball.physicsBody.categoryBitMask = ballCategory;
    self.ball.physicsBody.contactTestBitMask = paddleCategory;
    //self.ball.physicsBody.collisionBitMask = brickCategory;
    self.ball.physicsBody.usesPreciseCollisionDetection = YES;

    [self addChild:self.ball];
}

- (void)drawBottomBorder {
    //SKShapeNode *obj = [SKShapeNode
}

#pragma mark - Gesture Methods

- (void)dragPaddle:(UIPanGestureRecognizer *)gesture {

    // TODO Add UIView at Bottom of screen, that's where the gesture will be added to,
    // So that touching above the paddle will result in no movement of the paddle.

    SKAction *moveAction = nil;
    CGPoint trans = [gesture translationInView:self.view];

    if (SPECIAL_MODE) {

        if (self.paddle.position.y >= 160 && trans.y < 0) {

            moveAction =  [SKAction moveByX:trans.x y:0  duration:0];

        } else {

            moveAction =  [SKAction moveByX:trans.x y:-trans.y  duration:0];
        }

    } else {

        /* Normal BrickBreaker Method - Moving Along a Single Axis */
        moveAction =  [SKAction moveByX:trans.x y:0 duration:0];

    }

    [self.paddle runAction:moveAction];
    [gesture setTranslation:CGPointMake(0, 0) inView:self.view];

}

#pragma mark - Collision Methods

- (void)ball:(SKSpriteNode *)ball didCollideWithBrick:(SKSpriteNode *)brick {

    // TODO Let bricks fall with gravity, player has to dodge the bricks

    NSLog(@"Hit Brick");
}

- (void)ball:(SKSpriteNode *)ball didCollideWithPaddle:(SKSpriteNode *)paddle {

    NSLog(@"Hit Paddle");
}

#pragma mark - SKPhysicsContactDelegate Methods

- (void)didBeginContact:(SKPhysicsContact *)contact {

    SKPhysicsBody *firstBody, *secondBody; // ball, paddle

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {

        firstBody = contact.bodyA;
        secondBody = contact.bodyB;

    } else {

        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & ballCategory) != 0 &&
        (secondBody.categoryBitMask & paddleCategory) != 0) {
        
        [self ball:(SKSpriteNode *)firstBody.node didCollideWithPaddle:(SKSpriteNode *)secondBody.node];
    }
}




@end
