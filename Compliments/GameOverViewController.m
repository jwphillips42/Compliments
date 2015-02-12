//
//  GameOverViewController.m
//  Compliments
//
//  Created by Kevin Yao on 5/5/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "GameOverViewController.h"
#import "ResultsViewController.h"
#import "HighScore.h"
#import "HighScoreTable.h"
#define FONT_JS_STD(s) [UIFont fontWithName:@"JosefinSans" size:s]
#define FONT_PO_STD(s) [UIFont fontWithName:@"Poiret One" size:s]

@interface GameOverViewController () {
    int level;
    int score;
    BOOL isHighScore;
}

@end

@implementation GameOverViewController
@synthesize levelLabel;
@synthesize scoreLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    levelLabel.text = [NSString stringWithFormat:@"%d", level];
    
    _scoreTextLabel.font = FONT_PO_STD(20.0f);
    scoreLabel.font = FONT_PO_STD(16.0f);
    _levelTextLabel.font = FONT_PO_STD(20.0f);
    levelLabel.font = FONT_PO_STD(16.0f);
    
    _gameOverLabel.font = FONT_JS_STD(30.0f);
    _nextButton.titleLabel.font = FONT_PO_STD(18.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) passInScore: (int)inScore andLevel: (int)inLevel andIsHS: (BOOL) inIsHighScore {
    level = inLevel;
    score = inScore;
    
    isHighScore = inIsHighScore;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextScreen:(id)sender {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [currentDefaults objectForKey:@"name"];
    NSLog(@"name: %@", name);
    HighScore *temp = [[HighScore alloc] init];
    [temp setName: name];
    [temp setScore: score];
    HighScoreTable *highScoreArray;
    highScoreArray = [[HighScoreTable alloc] init];
    [highScoreArray loadHighscore];
    [highScoreArray addHighscore:temp];
    [highScoreArray saveHighscore];
    
    ResultsViewController *results = [self.storyboard instantiateViewControllerWithIdentifier:@"results"];
    [self presentViewController:results animated:YES completion:nil];
}
@end
