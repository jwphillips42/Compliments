//
//  Board.m
//  Compliments
//
//  Created by James Phillips on 4/7/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "Board.h"
#import "DataKeeper.h"
#import "Dot.h"
#import "DotAnimation.h"
#import "NSMutableArray_QueueAdditions.h"

@implementation Board
{
    /****   Game/Logic Variables   ****/
    int numericalBoard[9][9];   // Stores color value of each board location
    Dot* boardData[9][9];       // Stores CALayers of each board location
    
    int colorMixLookup[9][9];   // Stores results of color interaction
    DataKeeper *theDataKeeper;
    
    /****   Board Location Variables   ****/
    // int rowLen -> Public
    int startTop; // Starting x y coordinates of board
    int startLeft;
    
    /****   Color Variables   ****/
    struct CGColor *cgBlack;
    struct CGColor *cgWhite;
    struct CGColor *cgRed;
    struct CGColor *cgOrange;
    struct CGColor *cgYellow;
    struct CGColor *cgGreen;
    struct CGColor *cgBlue;
    struct CGColor *cgPurple;
    struct CGColor *cgGrey;
    int empty;
    int black;
    int white;
    int red;
    int orange;
    int yellow;
    int green;
    int blue;
    int purple;
    
    /****   Animation Variables   ****/
    NSMutableArray* animationBuffer;
    BOOL inAnimation;
    CGFloat ballMS;
}

@synthesize sideLength;
@synthesize nextColor;
@synthesize complimentSoundID;
@synthesize muteSound;

////////////////////////////////////////////
//
//   Board Initialization Functions
//
////////////////////////////////////////////

-(id) initPlusTabelAndSetupWithDataKeeper: (DataKeeper*) d
{
    self = [super init];
    if(self)
    {
        theDataKeeper = d;
        [self setupBoard];
        
        NSString* complimentSoundPath = [[NSBundle mainBundle] pathForResource:@"complimentSound" ofType:@"mp3"];
        NSURL* complimentSoundURL = [NSURL fileURLWithPath:complimentSoundPath];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)complimentSoundURL, &complimentSoundID);
        
        /*
         COLORS:
         0 - Blank
         1 - Black
         2 - White
         3 - Red
         4 - Orange
         5 - Yellow
         6 - Green
         7 - Blue
         8 - Purple
         */
        //Set up an array so that we don't have to calculate color mix values, just lookup.
        //NOTE : # > 2 indicates the mixed color that should be produced
        //       2 indicates complimentary colors, gives a white dot / point
        //       0, 1 shouldn't show up in the array, since no combination produces blank or black (might change later)
        //       -1 indicates that this is a situation that should occur, but the colors don't mix
        //       -2 indicates a situation that shouldn't happen (ex : trying to mix white and black)
        int temp[9][9] =
        {
            /*Blank*/   {-2, -2, -2, -2, -2, -2, -2, -2, -2},
            /*Black*/   {-2, -2, -2, -1, -1, -1, -1, -1, -1},
            /*White*/   {-2, -2, -2, -1, -1, -1, -1, -1, -1},
            /*Red*/     {-2, -1, -1, -1, -1,  4,  2,  8, -1},
            /*Orange*/  {-2, -1, -1, -1, -1, -1,  5,  2,  3},
            /*Yellow*/  {-2, -1, -1,  4, -1, -1, -1,  6,  2},
            /*Green*/   {-2, -1, -1,  2,  5, -1, -1, -1,  7},
            /*Blue */   {-2, -1, -1,  8,  2,  6, -1, -1, -1},
            /*Purple*/  {-2, -1, -1, -1,  3,  2,  7, -1, -1}
        };
        
        for(int i = 0; i < 9; i++){
            for(int j = 0; j < 9; j++){
                colorMixLookup[i][j] = temp[i][j];
            }
        }
    }
    return self;
}

// Setup board to new/initial state (for restarting and starting a game)
-(void) setupBoard
{
    //Set side length
    sideLength = 9;
    //Initialize the board to 0s
    for(int i = 0; i < sideLength; i++)
    {
        for(int j = 0; j < sideLength; j++)
        {
            numericalBoard[i][j] = 0;
        }
    }
    
    //Set the black dot
    numericalBoard[(sideLength/2)][(sideLength/2)] = 1;
    
    //Get a next color set up
    [self generateNextColor];
    
    //Grab info about whether to play game sounds from memory
    muteSound = [[NSUserDefaults standardUserDefaults] boolForKey:@"muteSounds"];
}

////////////////////////////////////////////
//
//   Helper Functions (Game Logic)
//
////////////////////////////////////////////

// Generates random Next Color
-(int)generateNextColor
{
    int toReturn = (arc4random() % 6) + 3;
    nextColor = toReturn;
    return toReturn;
}

// Checks to see if there is some valid move to be made. Used to determine whether the round is over.
-(BOOL)doesValidMoveExist
{
    //Iterate over every possible move...
    for(int i = 0; i < 4; i++)
    {
        //...If a move is valid...
        if([self isMoveValid:i]){
            //...Return YES...
            return YES;
        }
    }
    //...Otherwise, return No
    return NO;
}

-(void) makeRandomMove
{
    int direction = arc4random() % 4;
    
    for(int i = 0; i < 4; i++){
        if([self isMoveValid:direction]){
            [self sendCascade:direction];
            break;
        }
        else{
            direction++;
            if(direction > 3){
                direction = 0;
            }
        }
    }
}

/////////////////////////////////////////////////////////////
//
//   Implements move - with helper functions below
//
/////////////////////////////////////////////////////////////

-(void) sendCascade:(int)direction
{
    int pos = -1;
    int mixResult = -1;
    BOOL madeCompliment = NO;
    
    if([self isMoveValid:direction]){
        NSMutableArray *animDotList = [[NSMutableArray alloc] init];
        NSMutableArray *animDotList2 = [[NSMutableArray alloc] init];
        switch (direction) {
                //UP
            case 0:
                /*[CATransaction begin];
                 [CATransaction setCompletionBlock:^{
                 NSLog(@"Completion block");
                 }];*/
                //For every column on the board...
                for(int i = 0; i < sideLength; i++)
                {
                    //...Get the position of the most extreme dot (i.e. the one the current cascade will interact with)...
                    pos = [self getBottomDotInColumn:i];
                    
                    if(pos > -1){
                        
                        //...Check the result of that dot mixing with the new one...
                        mixResult = colorMixLookup[nextColor][numericalBoard[pos][i]];
                        //NSLog([NSString stringWithFormat:@"%d", mixResult]);
                        //...If that move shouldn't be happening, there's a problem....
                        if(mixResult == -2)
                        {
                            //...So set the position to -2, as a heads up.
                            numericalBoard[pos][i] = -2;
                        }
                        //...If the colors don't mix, but the move makes sense...
                        else if(mixResult == -1)
                        {
                            //...Check to see if that dot's placement makes the new one's legal, and if it is...
                            if(pos < sideLength-1 && pos > -1)
                            {
                                //...Place the new dot.
                                numericalBoard[pos + 1][i] = nextColor;
                                NSLog(@"Next color: %d", nextColor);
                                
                                DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:sideLength-1 ToCol:i Row:pos+1 Color:nextColor];
                                
                                [animDotList addObject:tempDA];
                            }
                        }
                        //...If the colors are complimentary...
                        else if(mixResult == white)
                        {
                            madeCompliment = YES;
                            numericalBoard[pos][i] = mixResult;
                            [theDataKeeper incrementScore];
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:sideLength-1 ToCol:i Row:pos Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:i Row:pos Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        else
                        {
                            numericalBoard[pos][i] = mixResult;
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:sideLength-1 ToCol:i Row:pos Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:i Row:pos Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        
                    }
                }
                //[CATransaction commit];
                break;
                //DOWN
            case 1:
                for(int i = 0; i < sideLength; i++)
                {
                    pos = [self getTopDotInColumn:i];
                    if(pos > -1)
                    {
                        mixResult = colorMixLookup[nextColor][numericalBoard[pos][i]];
                        
                        if(mixResult == -2)
                        {
                            //...So set the position to -2, as a heads up.
                            numericalBoard[pos][i] = -2;
                        }
                        else if(mixResult == -1)
                        {
                            if(pos > 0)
                            {
                                numericalBoard[pos - 1][i] = nextColor;
                                //[self createDotCol:i Row:pos-1 Color:nextColor];
                                
                                DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:0 ToCol:i Row:pos-1 Color:nextColor];
                                
                                [animDotList addObject:tempDA];
                            }
                        }
                        else if(mixResult == white)
                        {
                            madeCompliment = YES;
                            numericalBoard[pos][i] = mixResult;
                            [theDataKeeper incrementScore];
                            
                            //[self changeDotColorAtRow:pos Col:i Color:white];
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:0 ToCol:i Row:pos Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:i Row:pos Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        else
                        {
                            numericalBoard[pos][i] = mixResult;
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:i Row:0 ToCol:i Row:pos Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:i Row:pos Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        
                    }
                }
                
                break;
                //LEFT
            case 2:
                for(int i = 0; i < sideLength; i++)
                {
                    pos = [self getRightmostDotInRow:i];
                    if(pos > -1)
                    {
                        mixResult = colorMixLookup[nextColor][numericalBoard[i][pos]];
                        if(mixResult == -2)
                        {
                            numericalBoard[i][pos] = -2;
                        }
                        else if(mixResult == -1)
                        {
                            if(pos < sideLength - 1 && pos > -1)
                            {
                                numericalBoard[i][pos + 1] = nextColor;
                                //[self createDotCol:pos+1 Row:i Color:nextColor];
                                
                                DotAnimation *tempDA = [self newCreateAniDotFromCol:sideLength-1 Row:i ToCol:pos+1 Row:i Color:nextColor];
                                
                                [animDotList addObject:tempDA];
                            }
                        }
                        else if(mixResult == white)
                        {
                            madeCompliment = YES;
                            numericalBoard[i][pos] = mixResult;
                            [theDataKeeper incrementScore];
                            
                            //[self changeDotColorAtRow:i Col:pos Color:white];
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:sideLength-1 Row:i ToCol:pos Row:i Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:pos Row:i Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        else
                        {
                            numericalBoard[i][pos] = mixResult;
                            
                            //[self changeDotColorAtRow:i Col:pos Color:mixResult];
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:sideLength-1 Row:i ToCol:pos Row:i Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:pos Row:i Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                    }
                    
                }
                
                break;
                //RIGHT
            case 3:
                for(int i = 0; i < sideLength; i++)
                {
                    pos = [self getLeftmostDotInRow:i];
                    
                    if(pos > -1)
                    {
                        mixResult = colorMixLookup[nextColor][numericalBoard[i][pos]];
                        if(mixResult == -2)
                        {
                            numericalBoard[i][pos] = -2;
                        }
                        else if(mixResult == -1)
                        {
                            if(pos > 0)
                            {
                                numericalBoard[i][pos - 1] = nextColor;
                                //[self createDotCol:pos-1 Row:i Color:nextColor];
                                
                                DotAnimation *tempDA = [self newCreateAniDotFromCol:0 Row:i ToCol:pos-1 Row:i Color:nextColor];
                                
                                [animDotList addObject:tempDA];
                            }
                        }
                        else if(mixResult == white)
                        {
                            madeCompliment = YES;
                            numericalBoard[i][pos] = mixResult;
                            [theDataKeeper incrementScore];
                            
                            //[self changeDotColorAtRow:i Col:pos Color:white];
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:0 Row:i ToCol:pos Row:i Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:pos Row:i Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                        else
                        {
                            numericalBoard[i][pos] = mixResult;
                            
                            //[self changeDotColorAtRow:i Col:pos Color:mixResult];
                            
                            DotAnimation *tempDA = [self newCreateAniDotFromCol:0 Row:i ToCol:pos Row:i Color:nextColor];
                            
                            [animDotList addObject:tempDA];
                            
                            DotAnimation *temp2DA = [self newCreateAniDotChangeColourCol:pos Row:i Color:mixResult];
                            
                            [animDotList2 addObject:temp2DA];
                        }
                    }
                }
                
                break;
                //ERROR
            default:
                break;
        }//END SWITCH
        
        if (animDotList != nil && animDotList.count != 0)
            [animationBuffer enqueue:animDotList];
        if (animDotList2 != nil && animDotList2.count != 0)
            [animationBuffer enqueue:animDotList2];
        
        //If we made a compliment...
        if(madeCompliment){
            //Good place to put testing code
            //...and we're not muting the sounds...
            if(muteSound == NO){
                //...Play the sound.
                AudioServicesPlaySystemSound(complimentSoundID);
            }
        }
        
        if(inAnimation == false) {
            [self executeNextAnimation];
        }
        
        //Since the move was valid, generate the next color
        [self generateNextColor];
        [theDataKeeper resetTimer];
    }
}

// Check if move is valid
-(BOOL) isMoveValid:(int) direction{
    BOOL toReturn = NO;
    int pos = -1;
    int mixResult = -1;
    switch (direction) {
            //UP
        case 0:
            //For every column on the board...
            for(int i = 0; i < sideLength; i++)
            {
                //...Get the position of the most extreme dot (i.e. the one the current cascade will interact with)...
                pos = [self getBottomDotInColumn:i];
                
                //If the piece collides...
                if(pos > -1){
                    //... but doesn't mix, and that would put the piece off of the board ...
                    if(mixResult == -1 && pos >= sideLength-1)
                    {
                        //... Don't actually do anything. Just leave toReturn as NO. Weird structure, but
                        //it's easier to isolate this instance and put everything else in the else block.
                    }
                    else
                    {
                        //If we don't get caught by the if statement, it's a valid move
                        return YES;
                    }
                }
                //If the piece DOESN'T collide, then still leave toReturn as NO. (No code needed for this)
            }
            
            break;
            //DOWN
        case 1:
            for(int i = 0; i < sideLength; i++)
            {
                pos = [self getTopDotInColumn:i];
                //If the piece collides...
                if(pos > -1)
                {
                    mixResult = colorMixLookup[nextColor][numericalBoard[pos][i]];
                    
                    if(mixResult == -1 && pos <= 0)
                    {
                        //... Don't actually do anything. Just leave toReturn as NO. Weird structure, but
                        //it's easier to isolate this instance and put everything else in the else block.
                    }
                    else{
                        return YES;
                    }
                    
                }
                //If the piece DOESN'T collide, then still leave toReturn as NO. (No code needed for this)
            }
            
            break;
            //LEFT
        case 2:
            for(int i = 0; i < sideLength; i++)
            {
                pos = [self getRightmostDotInRow:i];
                if(pos > -1)
                {
                    mixResult = colorMixLookup[nextColor][numericalBoard[i][pos]];
                    if(mixResult == -1 && pos >= sideLength - 1)
                    {
                        //... Don't actually do anything. Just leave toReturn as NO. Weird structure, but
                        //it's easier to isolate this instance and put everything else in the else block.
                    }
                    else{
                        return YES;
                    }
                }
                //If the piece DOESN'T collide, then still leave toReturn as NO. (No code needed for this)
                
            }
            
            break;
            //RIGHT
        case 3:
            for(int i = 0; i < sideLength; i++)
            {
                pos = [self getLeftmostDotInRow:i];
                
                if(pos > -1)
                {
                    mixResult = colorMixLookup[nextColor][numericalBoard[i][pos]];
                    
                    if(mixResult == -1 && pos <= 0)
                    {
                        //... Don't actually do anything. Just leave toReturn as NO. Weird structure, but
                        //it's easier to isolate this instance and put everything else in the else block.
                    }
                    else
                    {
                        return YES;
                    }
                }
            }
            
            break;
            //ERROR
        default:
            break;
    }//END SWITCH
    
    return toReturn;
}

// Get the most extreme dots in each row/column
-(int) getTopDotInColumn:(int)col
{
    //Default to -1, indicating an empty column
    int toReturn = -1;
    //Run through the column...
    for(int i = sideLength - 1; i >= 0; i--)
    {
        //...If you find something that isn't empty space...
        if(numericalBoard[i][col] != 0)
        {
            //...Update toReturn, so it reflects the last dot seen.
            toReturn = i;
        }
    }
    //Return the last dot seen.
    return toReturn;
}

-(int) getBottomDotInColumn:(int)col
{
    int toReturn = -1;
    for(int i = 0; i < sideLength; i++)
    {
        if(numericalBoard[i][col] != 0)
        {
            toReturn = i;
        }
    }
    return toReturn;
}

-(int) getLeftmostDotInRow:(int)row
{
    int toReturn = -1;
    for(int i = sideLength - 1; i >= 0; i--)
    {
        if(numericalBoard[row][i] != 0)
        {
            toReturn = i;
        }
    }
    return toReturn;
}

-(int) getRightmostDotInRow:(int)row
{
    int toReturn = -1;
    for(int i = 0; i < sideLength; i++)
    {
        if(numericalBoard[row][i] != 0)
        {
            toReturn = i;
        }
    }
    return toReturn;
}

/////////////////////////////////////////////////////////////////////////////
//
//  Graphics Functions: Initiating Functions + Helper Functions
//
/////////////////////////////////////////////////////////////////////////////

// Initialize Board Graphics
-(void)setBoardDots:(int)dots withLeft:(int)left withTop:(int)top withWidth:(int)width withHeight:(int)height withRadius:(int)r{
    
    [self initColors];
    
    _board = [CALayer layer];
    
    [_board setFrame:CGRectMake(left,top,width,height)];
    [_board setBackgroundColor:cgGrey];
    
    [_board setCornerRadius:r];
    
    [_board setNeedsDisplay];
    
    _rowLen = width/(dots*2+1);
    startLeft = left;
    startTop = top;
    inAnimation = false;
    animationBuffer = [[NSMutableArray alloc] init];
    ballMS = 10; // 10 balls per second
    
    [self createDotCol:4 Row:4 Color: black];
    //[self createAniDotFromCol:1 Row:1 ToCol:5 Row:5 Color:1];
    /*NSMutableArray *testing = [[NSMutableArray alloc] init];
     [testing addObject: [self newCreateAniDotFromCol:1 Row:1 ToCol:5 Row:5 Color:5]];
     [testing addObject: [self newCreateAniDotFromCol:2 Row:2 ToCol:6 Row:6 Color:6]];
     
     [animationBuffer enqueue:testing];
     
     NSMutableArray *testing2 = [[NSMutableArray alloc] init];
     [testing2 addObject: [self daChangeColorAtRow:5 Col:5 Color:6]];
     [testing2 addObject: [self daChangeColorAtRow:6 Col:6 Color:6]];
     
     [animationBuffer enqueue:testing2];
     
     [self executeNextAnimation];*/
    
}

// Function to create Dot at Point COL & ROW
-(void)createDotCol:(int)col Row:(int)row Color:(int)colour {
    Dot *newDot = [[Dot alloc] init];
    [newDot setCol: col];
    [newDot setRow: row];
    [newDot setColour: colour];
    [newDot setAdded: false];
    
    boardData[col][row] = newDot;
    
    CALayer *dotLayer = [[CALayer alloc] init];
    
    [dotLayer setFrame:CGRectMake(startLeft+_rowLen+_rowLen*col*2,startTop+_rowLen+_rowLen*row*2,_rowLen,_rowLen)];
    NSLog(@"In-Next Colour: %d", colour);
    struct CGColor *nextC = [self returnCGColor:colour];
    [dotLayer setBackgroundColor:nextC];
    [dotLayer setCornerRadius:_rowLen/2];
    [dotLayer setNeedsDisplay];
    
    [newDot setLayer:dotLayer];
}

// Create Dot with animation
-(void) createAniDotFromCol:(int)init_col Row:(int)init_row ToCol:(int)final_col Row:(int)final_row Color:(int)colour {
    
    CGFloat ballRadius = _rowLen/2;
    
    Dot *newDot = [[Dot alloc] init];
    [newDot setCol: final_col];
    [newDot setRow: final_row];
    [newDot setColour: colour];
    [newDot setAdded: false];
    
    boardData[final_col][final_row] = newDot;
    
    CALayer *dotLayer = [[CALayer alloc] init];
    
    [dotLayer setFrame:CGRectMake(startLeft+_rowLen+_rowLen*init_col*2,startTop+_rowLen+_rowLen*init_row*2,_rowLen,_rowLen)];
    [dotLayer setBackgroundColor:[self returnCGColor:colour]];
    [dotLayer setCornerRadius:ballRadius];
    [dotLayer setNeedsDisplay];
    
    [newDot setLayer:dotLayer];
    
    CGPoint endPoint = CGPointMake(startLeft+_rowLen+_rowLen*final_col*2+ballRadius, startTop+_rowLen+_rowLen*final_row*2+ballRadius);
    CGPoint currentPoint = CGPointMake(startLeft+_rowLen+_rowLen*init_col*2+ballRadius, startTop+_rowLen+_rowLen*init_row*2+ballRadius);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    [anim setFromValue:[NSValue valueWithCGPoint:currentPoint]];
    [anim setToValue:[NSValue valueWithCGPoint:endPoint]];
    [anim setDelegate:self];
    [anim setDuration:1];
    
    [dotLayer setPosition:endPoint];
    [dotLayer addAnimation:anim forKey:@"position"];
}
-(DotAnimation*) newCreateAniDotFromCol:(int)init_col Row:(int)init_row ToCol:(int)final_col Row:(int)final_row Color:(int)colour {
    
    //////////////
    // DOT PART //
    //////////////
    
    CGFloat ballRadius = _rowLen/2;
    
    Dot *newDot = [[Dot alloc] init];
    [newDot setCol: final_col];
    [newDot setRow: final_row];
    [newDot setColour: colour];
    [newDot setAdded: false];
    
    boardData[final_col][final_row] = newDot;
    
    CALayer *dotLayer = [[CALayer alloc] init];
    
    [dotLayer setFrame:CGRectMake(startLeft+_rowLen+_rowLen*init_col*2,startTop+_rowLen+_rowLen*init_row*2,_rowLen,_rowLen)];
    [dotLayer setBackgroundColor:[self returnCGColor:colour]];
    [dotLayer setCornerRadius:ballRadius];
    [dotLayer setNeedsDisplay];
    
    [newDot setLayer:dotLayer];
    
    ///////////////
    // ANIM PART //
    ///////////////
    
    CGFloat distance = sqrt((final_col - init_col)*(final_col - init_col) + (final_row-init_row)*(final_row-init_row));
    CGFloat duration = distance/ballMS;
    
    CGPoint endPoint = CGPointMake(startLeft+_rowLen+_rowLen*final_col*2+ballRadius, startTop+_rowLen+_rowLen*final_row*2+ballRadius);
    CGPoint currentPoint = CGPointMake(startLeft+_rowLen+_rowLen*init_col*2+ballRadius, startTop+_rowLen+_rowLen*init_row*2+ballRadius);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    [anim setFromValue:[NSValue valueWithCGPoint:currentPoint]];
    [anim setToValue:[NSValue valueWithCGPoint:endPoint]];
    [anim setDelegate:self];
    [anim setDuration:duration];
    
    [dotLayer setPosition:endPoint];
    
    DotAnimation *retValue = [[DotAnimation alloc] init];
    retValue.animationType = 1;
    retValue.anim = anim;
    retValue.dot = newDot;
    
    return retValue;
}

-(DotAnimation*) newCreateAniDotChangeColourCol:(int)i Row:(int)pos Color:(int)mixResult {
    Dot *tempDot = [self retreiveDotAtCol:i Row:pos];
    
    DotAnimation *temp2DA = [[DotAnimation alloc] init];
    temp2DA.dot = tempDot;
    
    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    colorsAnimation.values = [NSArray arrayWithObjects:
                              (id)tempDot.layer.backgroundColor,
                              (id)[self returnCGColor:mixResult], nil];
    colorsAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:1.0], nil];
    colorsAnimation.calculationMode = kCAAnimationPaced;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.fillMode = kCAFillModeForwards;
    colorsAnimation.duration = 0.3f;
    
    temp2DA.animationType = 2;
    temp2DA.anim = colorsAnimation;
    
    return temp2DA;
}

// Helper Function - retrieve DOT object at COL & ROW
-(Dot*)retreiveDotAtCol:(int)col Row:(int)row {
    return boardData[col][row];
}

// After adding Dot, outer view has to retreive list of new layers and append to the layer itself
// Returns Array of CALayers that have not been added to the View's Layer list
-(NSMutableArray*)returnNewLayers {
    NSMutableArray *returnVal = [[NSMutableArray alloc] init];
    for(int i=0; i<9; i++) {
        for(int j=0; j<9; j++){
            if(boardData[i][j] != NULL){
                if(boardData[i][j].added == FALSE) {
                    NSLog(@"inIt:%d %d",i,j);
                    [returnVal addObject:boardData[i][j].layer];
                }
            }
        }
    }
    return returnVal;
}

-(Dot*)deleteDotAtRow: (int)row Col:(int)col {
    Dot* toBeDeleted = boardData[row][col];
    if(toBeDeleted != NULL) {
        boardData[col][row] = NULL;
        return toBeDeleted;
    }
    return NULL;
}

-(void)changeDotColorAtRow: (int)row Col:(int)col Color:(int)colour {
    Dot* change = boardData[col][row];
    struct CGColor* changeToColour = [self returnCGColor:colour];
    [change.layer setBackgroundColor: changeToColour];
}

-(DotAnimation*) daChangeColorAtRow: (int)row Col:(int)col Color:(int)colour {
    Dot *animDot = [self retreiveDotAtCol:col Row:row];
    
    //Create animation
    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    colorsAnimation.values = [NSArray arrayWithObjects:
                              (id)animDot.layer.backgroundColor,
                              (id)[self returnCGColor:nextColor], nil];
    colorsAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:1.0], nil];
    colorsAnimation.calculationMode = kCAAnimationPaced;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.fillMode = kCAFillModeForwards;
    colorsAnimation.duration = 1.0f;
    
    //Add animation
    //[animDot.layer addAnimation:colorsAnimation forKey:nil];
    
    DotAnimation *retValue = [[DotAnimation alloc] init];
    retValue.animationType = 2;
    retValue.anim = colorsAnimation;
    retValue.dot = animDot;
    
    return retValue;
}

// Set Private Color Variables
-(void)initColors {
    cgBlack = CGColorRetain ([UIColor colorWithRed:10.0f/255 green:10.0f/255 blue:10.0f/255 alpha:1.0f].CGColor);
    cgWhite = CGColorRetain ([UIColor colorWithRed:255.0f/255 green:255.0f/255 blue:255.0f/255 alpha:1.0f].CGColor);
    //Red(RGB): 204,51,63
    cgRed = CGColorRetain ([UIColor colorWithRed:204.0f/255 green:51.0f/255 blue:63.0f/255 alpha:1.0f].CGColor);
    //Green(RGB): 136,196,37
    cgGreen = CGColorRetain ([UIColor colorWithRed:136.0f/255 green:196.0f/255 blue:37.0f/255 alpha:1.0f].CGColor);
    //Blue(RGB): 0,160,176
    cgBlue = CGColorRetain ([UIColor colorWithRed:0.0f/255 green:160.0f/255 blue:176.0f/255 alpha:1.0f].CGColor);
    //Yellow(RGB): 237,201,81
    cgYellow = CGColorRetain ([UIColor colorWithRed:237.0f/255 green:201.0f/255 blue:81.0f/255 alpha:1.0f].CGColor);
    //Orange(RGB): 255, 157, 92
    cgOrange = CGColorRetain ([UIColor colorWithRed:255.0f/255 green:157.0f/255 blue:92.0f/255 alpha:1.0f].CGColor);
    //Purple(RGB): 113, 74, 145
    cgPurple = CGColorRetain ([UIColor colorWithRed:113.0f/255 green:74.0f/255 blue:145.0f/255 alpha:1.0f].CGColor);
    
    //Grey(RGB): 211,211,211
    cgGrey = CGColorRetain ([UIColor colorWithRed:211.0f/255 green:211.0f/255 blue:211.0f/255 alpha:1.0f].CGColor);
    
    /*
     COLORS:
     0 - Blank
     1 - Black
     2 - White
     3 - Red
     4 - Orange
     5 - Yellow
     6 - Green
     7 - Blue
     8 - Purple
     */
    empty = 0;
    black = 1;
    white = 2;
    red = 3;
    orange = 4;
    yellow = 5;
    green = 6;
    blue = 7;
    purple = 8;
}

// Helper function for color int => color CGColor
-(struct CGColor*) returnCGColor:(int)col {
    struct CGColor *returnCG;
    returnCG = cgBlack;
    if(col == black)
        returnCG = cgBlack;
    else if(col == red)
        returnCG = cgRed;
    else if(col == green)
        returnCG = cgGreen;
    else if(col == blue)
        returnCG = cgBlue;
    else if(col == white)
        returnCG = cgWhite;
    else if (col == orange)
        returnCG = cgOrange;
    else if (col == purple)
        returnCG = cgPurple;
    else if (col == yellow)
        returnCG = cgYellow;
    return returnCG;
}

-(void) executeNextAnimation {
    
    NSLog(@"IN EXECUTE FUNC");
    
    NSMutableArray *animationArray =  [animationBuffer dequeue];
    
    if(animationArray == nil) {
        return;
    }
    
    inAnimation = true;
    
    NSLog(@"t1");
    
    DotAnimation *animDotOne = animationArray[0];
    
    int type = animDotOne.animationType;
    
    if(type == 1) {
        //NSLog(@"Type One");
        for (DotAnimation *d in animationArray) {
            //NSLog(@"D Count");
            [self.belongToView.view.layer addSublayer:d.dot.layer];
            boardData[d.dot.col][d.dot.row] = d.dot;
        }
        //[self.belongToView updateBoard];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self animationCompletionCall];
        }];
        for(DotAnimation *d in  animationArray) {
            [d.dot.layer addAnimation:d.anim forKey:nil];
        }
        [CATransaction commit];
        
    } else if (type == 2) {
        NSLog(@"Type Two");
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self animationCompletionCall];
        }];
        for(DotAnimation *d in  animationArray) {
            [d.dot.layer addAnimation:d.anim forKey:nil];
        }
        [CATransaction commit];
        
    }
    
    NSLog(@"END EXECUTE FUNC");
}

-(void) animationCompletionCall {
    inAnimation = false;
    
    if(animationBuffer.count > 0)
        [self executeNextAnimation];
}

/////////////////////////////////////////////////////////////////////////////
//
//  Text Display Functions - (Temporary before Graphics Implementation)
//
/////////////////////////////////////////////////////////////////////////////

-(NSString*) getArray
{
    NSString *boardAsString = @"";
    for(int i = 0; i < sideLength; i++)
    {
        //Grab each row individually, with line breaks appended to the end of each
        boardAsString = [NSString stringWithFormat:@"%@%@", boardAsString, [self getRow:i]];
    }
    return boardAsString;
}
//ARRAY UPDATES

//Just gets the information for a single row of the array, to make it easier to include line breaks
-(NSString*) getRow:(int)rowNumber
{
    NSString *toReturn = @"";
    for(int i = 0; i < sideLength; i++)
    {
        toReturn = [NSString stringWithFormat: @"%@%d", toReturn, numericalBoard[rowNumber][i]];
    }
    toReturn = [NSString stringWithFormat:@"%@\r\n", toReturn];
    
    return toReturn;
}

@end

