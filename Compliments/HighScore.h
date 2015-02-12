//
//  HighScore.h
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighScore : NSObject <NSCoding>

@property NSInteger score;
@property NSString *name;
@property NSInteger time;


@end
