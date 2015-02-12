//
//  ViewController.h
//  Compliments
//
//  Created by James Phillips on 4/7/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Board;
@class DataKeeper;

@interface ViewController : UIViewController

//UI STUFF
//LABELS
@property (weak, nonatomic) IBOutlet UILabel *testArrayLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextColorLabel;
@property CALayer *nextDotLayer;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *timerProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *scoreWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextColorWordLabel;

@property (weak, nonatomic) IBOutlet UILabel *levelWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorWheelLabel;


//BUTTONS

@property Board *theBoard;
@property DataKeeper *theDataKeeper;


//INTERNAL METHODS
-(void) updateBoard;

@end
