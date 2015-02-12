//
//  HighScoreTable.h
//  Compliments
//
//  Created by Kevin Yao on 5/5/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HighScore.h"

@interface HighScoreTable : NSObject

@property NSMutableArray *highscoreTable;

-(BOOL) isHighscore: (int) score;

-(void) addHighscore: (HighScore*) hscore;

-(void) loadHighscore;
-(void) saveHighscore;
-(void) clearHighscore;



@end

