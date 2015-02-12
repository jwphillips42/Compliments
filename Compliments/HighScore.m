//
//  HighScore.m
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//  Highscore tables from faizan aziz

#import "HighScore.h"

@implementation HighScore

@synthesize score = _score;
@synthesize name = _name;
@synthesize time = _time;

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_score] forKey:@"_score"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_time] forKey:@"_time"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _score = [[aDecoder decodeObjectForKey:@"_score"]intValue];
    _name = [aDecoder decodeObjectForKey:@"_name"];
    _time = [[aDecoder decodeObjectForKey:@"_time"]intValue];
    return self;
}

@end
