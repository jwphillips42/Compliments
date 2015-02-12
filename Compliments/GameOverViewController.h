//
//  GameOverViewController.h
//  Compliments
//
//  Created by Kevin Yao on 5/5/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameOverViewController : UIViewController

-(void) passInScore: (int)inScore andLevel: (int)inLevel andIsHS: (BOOL) inIsHighScore;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameOverLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)nextScreen:(id)sender;


@end
