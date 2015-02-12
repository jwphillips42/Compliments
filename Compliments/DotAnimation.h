//
//  DotAnimation.h
//  Compliments
//
//  Created by tester on 5/3/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dot.h"

@interface DotAnimation : NSObject

@property Dot* dot;
@property CAAnimation* anim;

@property int animationType;
// 1 -> Add new dot layers and animation to location
// 2 -> Change dot colour
// 3 -> Delete original dot
@end
