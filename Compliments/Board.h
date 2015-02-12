//
//  Board.h
//  Compliments
//
//  Created by James Phillips on 4/7/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "Dot.h"
#import "DotAnimation.h"
#import "ViewController.h"
@class DataKeeper;

@interface Board : NSObject

@property int sideLength;
@property int nextColor;
@property int rowLen;
@property CALayer *board; // CALayer for board background
@property ViewController *belongToView; // The view this board belongs to
@property SystemSoundID complimentSoundID;
@property BOOL muteSound;

//Internal Stuff
-(id) initPlusTabelAndSetupWithDataKeeper:(DataKeeper*) d;
-(void)setupBoard;
-(int)generateNextColor;
-(BOOL)doesValidMoveExist;
-(BOOL)isMoveValid:(int)direction;
-(void)makeRandomMove;

//Graphics Functions
-(void) setBoardDots:(int)dots withLeft:(int)left withTop:(int)top withWidth:(int)width withHeight:(int)height withRadius:(int)r;
-(void)createDotCol:(int)col Row:(int)row Color:(int)colour;
-(void) createAniDotFromCol:(int)init_col Row:(int)init_row ToCol:(int)final_col Row:(int)final_row Color:(int)colour;
-(DotAnimation*) newCreateAniDotFromCol:(int)init_col Row:(int)init_row ToCol:(int)final_col Row:(int)final_row Color:(int)colour;
-(Dot*)deleteDotAtRow: (int)row Col:(int)col;
-(struct CGColor*) returnCGColor:(int)col;

-(NSMutableArray*)returnNewLayers;

//Reacting to Buttons (Core method and helpers)
-(void)sendCascade:(int)direction;
-(int) getTopDotInColumn:(int)col;
-(int) getBottomDotInColumn:(int)col;
-(int) getLeftmostDotInRow:(int)row;
-(int) getRightmostDotInRow:(int)row;

//Feeding Back Information
-(NSString*) getRow:(int)rowNumber;
-(NSString*) getArray;
@end