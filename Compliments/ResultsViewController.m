//
//  ResultsViewController.m
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "ResultsViewController.h"
#define FONT_JS_STD(s) [UIFont fontWithName:@"JosefinSans" size:s]
#define FONT_PO_STD(s) [UIFont fontWithName:@"Poiret One" size:s]


@interface ResultsViewController()
{
    NSString* playerName;
    int gameScore;
}

@end

@implementation ResultsViewController
@synthesize Name;
@synthesize highScoreTableView;
@synthesize scoreLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [Name resignFirstResponder];
    
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [Name resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.highScoreTableView.dataSource = self;
    
    highScoreArray = [[HighScoreTable alloc] init];
    
    [highScoreArray loadHighscore];
    [highScoreTableView reloadData];
    
    scoreLabel.text = [NSString stringWithFormat:@"%d",gameScore];
    
    Name.delegate = self;
    
    _highScoreLabel.font = FONT_JS_STD(28);
    _homeButton.titleLabel.font = FONT_PO_STD(18);
    _againButton.titleLabel.font = FONT_PO_STD(18);
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [highScoreArray.highscoreTable count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  -  %d", [[highScoreArray.highscoreTable objectAtIndex:indexPath.row]name],(int)[[highScoreArray.highscoreTable objectAtIndex:indexPath.row]score] ];
    cell.textLabel.font = FONT_PO_STD(18);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(void) setCurrentName: (NSString*)currentName
{
    playerName = currentName;
}
-(void) setCurrentScore: (int) currentScore
{
    gameScore = currentScore;
}

- (IBAction)addToLibrary:(id)sender {
    HighScore *temp = [[HighScore alloc ] init];
    [temp setName:[Name text]];
    [temp setScore:gameScore];
    [highScoreArray loadHighscore];
    [highScoreArray addHighscore:temp];
    //[self sortArray];
    [highScoreTableView reloadData];
    [highScoreArray saveHighscore];
    NSLog(@"%@",playerName);

    
    /*NSLog(@"%i",(int)[highScoreArray count]);
    for(int i = 0; i < [highScoreArray count]; i++)
    {
        NSLog(@"%i",(int)[[highScoreArray objectAtIndex:i] score]);
    }*/
}

- (IBAction)remove:(id)sender {
    [highScoreArray clearHighscore];
    [highScoreTableView reloadData];
}
 
@end
