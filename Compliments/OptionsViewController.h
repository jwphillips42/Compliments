//
//  OptionsViewController.h
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighScoreTable.h"
#import "ResultsViewController.h"

@interface OptionsViewController : UIViewController<UITextFieldDelegate>
{
    HighScoreTable* highScoreArray;
    NSString *name;
    BOOL stopMusic;
    BOOL muteSounds;
}

@property (weak, nonatomic) IBOutlet UITextField *playerName;
- (IBAction)changeName:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabelText;
@property (weak, nonatomic) IBOutlet UILabel *musicLabelText;
@property (weak, nonatomic) IBOutlet UILabel *soundLabelText;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *musicSegControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *soundSegControl;

@end
