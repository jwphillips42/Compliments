//
//  DataKeeper.m
//  Compliments
//
//  Created by James Phillips on 4/22/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "DataKeeper.h"

@implementation DataKeeper{
    NSTimer* updateTimer;
    ViewController* gameViewController;
}

@synthesize score;
@synthesize moveTimer;
@synthesize defaultTimer;
@synthesize level;



-(id) initWithVC:(ViewController *)theVC{
    self = [super init];
    if(self)
    {
        level = 1;
        score = 0;
        defaultTimer = 15.0;
        moveTimer = defaultTimer;
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        gameViewController = theVC;
        gameViewController.levelLabel.text = [NSString stringWithFormat:@"%d", level];
    }
    return self;
}

-(void)tick:(NSTimer *) theTimer{
    moveTimer -= 0.1;
    if(moveTimer <= 0){
        [self resetTimer];
        [gameViewController.theBoard makeRandomMove];
        [gameViewController updateBoard];
    }
    [gameViewController.timerProgressBar setProgress:(1 - ((float) moveTimer / (float)defaultTimer)) animated: YES];
}

-(void)resetTimer
{
    moveTimer = defaultTimer;
    [gameViewController.timerProgressBar setProgress:(1 - (moveTimer / defaultTimer)) animated: YES];
}

-(void)incrementScore
{
    score += 10;
    if(score % 50 == 0 && defaultTimer > 5){
        defaultTimer /= 2;
        level++;
        gameViewController.levelLabel.text = [NSString stringWithFormat:@"%d", level];
    }
}

@end
