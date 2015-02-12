//
//  DataKeeper.h
//  Compliments
//
//  Created by James Phillips on 4/22/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//


/*
 *   The Data Keeper keeps track of all of the general information about a game that exists beyond the board.
 *   It's in charge of things like Score, Timer, Level, etc, but isn't involved with shuffling pieces around.
 */


#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "Board.h"


@interface DataKeeper : NSObject

@property int moves;
@property int score;
@property float moveTimer;
@property float defaultTimer;
@property int level;

-(id)initWithVC:(ViewController*) theVC;
-(void)resetTimer;
-(void)incrementScore;

@end
