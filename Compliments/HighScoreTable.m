//
//  HighScoreTable.m
//  Compliments
//
//  Created by Kevin Yao on 5/5/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "HighScoreTable.h"
#import "HighScore.h"
#define NUM_HS 10

@implementation HighScoreTable

@synthesize highscoreTable;

-(BOOL) isHighscore: (int) score
{
    for(int i = 0; i < highscoreTable.count; i++)
    {
        if([[highscoreTable objectAtIndex:i] score] < score){
            return YES;
        }
    }
    return NO;
}

-(void) addHighscore: (HighScore*)hscore
{
    
    int minIndex = 0;
    
    if([highscoreTable count] < NUM_HS)
    {
        [highscoreTable addObject:hscore];
    }
    else
    {
        HighScore *minTemp = [highscoreTable objectAtIndex:0];
        for(int i = 0; i < NUM_HS; i++)
        {
            if([[highscoreTable objectAtIndex:i] score] < minTemp.score){
                minTemp = [highscoreTable objectAtIndex: i];
                minIndex = i;
            }
        }
        if(minTemp.score < hscore.score)
        {
            [highscoreTable replaceObjectAtIndex:minIndex withObject:hscore];
        }
        
    }
    
    [self sortHighscores];
}

-(void) loadHighscore
{
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [currentDefaults objectForKey:@"highscores"];
    if(data != nil)
    {
        NSArray *oldArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(oldArray != nil)
            highscoreTable = [[NSMutableArray alloc] initWithArray:oldArray];
        else
            highscoreTable = [[NSMutableArray alloc] init];
    }
    
    [self sortHighscores];

}
-(void) saveHighscore
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:highscoreTable] forKey:@"highscores"];

}
-(void) sortHighscores
{
    NSArray *sortedArray;
    
    NSSortDescriptor *scoreDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObject:scoreDescriptor];
    sortedArray = [highscoreTable sortedArrayUsingDescriptors:sortDescriptor];
    highscoreTable = [sortedArray mutableCopy];
}

-(void) clearHighscore
{
    highscoreTable = [[NSMutableArray alloc] init];
    [self saveHighscore];
    
}

@end
