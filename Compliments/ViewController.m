//
//  ViewController.m
//  Compliments
//
//  Created by James Phillips on 4/7/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "ViewController.h"
#import "GameOverViewController.h"
#import "Board.h"
#import "DataKeeper.h"
#define FONT_JS_STD(s) [UIFont fontWithName:@"JosefinSans" size:s]
#define FONT_PO_STD(s) [UIFont fontWithName:@"Poiret One" size:s]


@interface ViewController ()

@end

@implementation ViewController

@synthesize testArrayLabel;
@synthesize theBoard;
@synthesize nextColorLabel;
@synthesize scoreLabel;
@synthesize levelLabel;
@synthesize timerProgressBar;
@synthesize theDataKeeper;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // INITIALIZE BOARD and BOARD DATA
    theDataKeeper = [[DataKeeper alloc]initWithVC:self];
    theBoard = [[Board alloc] initPlusTabelAndSetupWithDataKeeper:theDataKeeper];
    [theBoard setupBoard];
    theBoard.belongToView = self; // hook back to self
    testArrayLabel.numberOfLines = 0;
    
    // INITIALIZE BOARD GRAPHICS
    CGFloat margins = 35.0f;
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat boardWidth = screenWidth - (margins * 2);
    
    [theBoard setBoardDots:9 withLeft:margins withTop:80 withWidth:boardWidth withHeight:boardWidth withRadius:5];
    
    [self.view.layer insertSublayer:theBoard.board atIndex:0];
    
    // ADD DOT FOR NEXT COLOR INDICATOR
    CGPoint nextLabelPos = nextColorLabel.center;
    _nextDotLayer = [[CALayer alloc] init];
    int rowLen = theBoard.rowLen;
    
    [_nextDotLayer setFrame:CGRectMake(nextLabelPos.x-rowLen,nextLabelPos.y-rowLen/2,rowLen,rowLen)];
    struct CGColor *nextC = [theBoard returnCGColor:1];
    [_nextDotLayer setBackgroundColor:nextC];
    [_nextDotLayer setCornerRadius:rowLen/2];
    [_nextDotLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:_nextDotLayer];
    
    [self updateBoard];
    
    NSMutableArray *returnVal = [theBoard returnNewLayers];
    for(CALayer *iterateLayer in returnVal){
        [self.view.layer addSublayer:iterateLayer];
    }
    
    // FONTS
    _scoreWordLabel.font = FONT_PO_STD(20.0f);
    _nextColorWordLabel.font = FONT_PO_STD(18.0f);
    scoreLabel.font = FONT_PO_STD(16.0f);
    _levelWordLabel.font = FONT_PO_STD(20.0f);
    levelLabel.font = FONT_PO_STD(16.0f);
    
    // Colour Wheel
    
    int r = 20;
    
    _colorWheelLabel.text = @"";
    
    CALayer *circleDots;
    
    CGPoint cwl = _colorWheelLabel.center;
    for(int i = 0; i < 6; i++) {
        CGPoint draw;
        draw.x = r * cos(2*M_PI*(i/6.0f));
        draw.y = r * sin(2*M_PI*(i/6.0f));
        
        circleDots = [[CALayer alloc] init];
        
        [circleDots setFrame:CGRectMake(cwl.x-draw.y,cwl.y-draw.x,rowLen,rowLen)];
        struct CGColor *nextC = [theBoard returnCGColor:i+3];
        [circleDots setBackgroundColor:nextC];
        [circleDots setCornerRadius:rowLen/2];
        [circleDots setNeedsDisplay];
        
        [self.view.layer addSublayer:circleDots];
        
        NSLog(@"2pi: %f", M_PI);
        NSLog(@"%f %f", draw.x, draw.y);
    }
    
    
    
    // SWIPE CONTROLLERS
    
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    //leftswipe
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    //downswipe
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipe];
    
    //upswipe
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//INTERNAL STUFF

//Generic update, probably called frequently. Don't necessarily need to update next color this often, but handy for testing
-(void) updateBoard
{
    //NSString *toDisplay = [theBoard getArray];
    //testArrayLabel.text = toDisplay;
    //nextColorLabel.text = [NSString stringWithFormat:@"%d", [theBoard nextColor]];
    [_nextDotLayer setBackgroundColor:[theBoard returnCGColor:theBoard.nextColor]];
    scoreLabel.text = [NSString stringWithFormat:@"%d", [theDataKeeper score]];
    
    // Update Graphics Layers
    /*NSMutableArray *returnVal = [theBoard returnNewLayers];
     for(CALayer *iterateLayer in returnVal){
     [self.view.layer addSublayer:iterateLayer];
     }*/
    
    //Here's the hook for transitioning to the results screen / playing any end-of-round animation:
    if(![theBoard doesValidMoveExist])
    //if(theDataKeeper.score > 40)
    {
        //Don't actually want this long-term, just for testing
        //gotoButton.hidden = NO;
        GameOverViewController *gameover = [self.storyboard instantiateViewControllerWithIdentifier:@"game_over"];
        [gameover passInScore:theDataKeeper.score andLevel:theDataKeeper.level andIsHS:NO];
        [self presentViewController:gameover animated:YES completion:nil];
    }
}

// SWIPES

-(void)didSwipe: (UISwipeGestureRecognizer*) sender
{
    UISwipeGestureRecognizerDirection direction = sender.direction;
    
    switch (direction)
    {
        case UISwipeGestureRecognizerDirectionRight:
            [theBoard sendCascade:3];
            [self updateBoard];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [theBoard sendCascade:2];
            [self updateBoard];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [theBoard sendCascade:1];
            [self updateBoard];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [theBoard sendCascade:0];
            [self updateBoard];
            break;
    }
}


- (IBAction)gotoResults:(id)sender {
    
}
@end
