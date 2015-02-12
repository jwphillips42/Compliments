//
//  Dot.h
//  Compliments
//
//  Created by Jason Leung on 5/1/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

//
//  Dot is an object wrapper for the graphics portion of each Dot
//  Mainly used for storing the CALayer - for later removal
//  Along with flags to indication the animation stage/rendering stage of each individual dot
//


#import <Foundation/Foundation.h>

@interface Dot : NSObject

@property int col;  // COLUMN of dot
@property int row;  // ROW of dot

@property int colour;   // COLOUR of dot

@property int state;    // STATE of dot rendering *not used for now*
@property BOOL added;   // BOOLEAN value for whether Dot CALayer has been added (displayed)

@property CALayer* layer;   // CALayer for displaying of Dots

@end
