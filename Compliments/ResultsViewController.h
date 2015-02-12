//
//  ResultsViewController.h
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighScore.h"
#import "ViewController.h"
#import "HighScoreTable.h"
#import "OptionsViewController.h"



@interface ResultsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate>
{
    HighScoreTable* highScoreArray;
}
@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) NSMutableArray *array;
- (IBAction)addToLibrary:(id)sender;
- (IBAction)remove:(id)sender;
-(void) setCurrentName: (NSString*)currentName;
-(void) setCurrentScore: (int) currentScore;
@property (weak, nonatomic) IBOutlet UITableView *highScoreTableView;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *againButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

@end
