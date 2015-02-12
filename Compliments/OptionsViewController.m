//
//  OptionsViewController.m
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "OptionsViewController.h"
#import "AppDelegate.h"
#define FONT_JS_STD(s) [UIFont fontWithName:@"JosefinSans" size:s]
#define FONT_PO_STD(s) [UIFont fontWithName:@"Poiret One" size:s]

@interface OptionsViewController ()

@end

@implementation OptionsViewController
@synthesize playerName;
@synthesize musicSegControl;
@synthesize soundSegControl;

//Reference to the App Delegate, used for stopping background music
AppDelegate* app;

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
    playerName.delegate = self;
    highScoreArray = [[HighScoreTable alloc]init];
    [highScoreArray loadHighscore];
    HighScore* temp = [[HighScore alloc] init];
    name = [temp name];
    playerName.text = name;
    
    //Grab a reference to the App Delegate, so we can adjust the background music
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Base this boolean on stoping, rather than starting, since boolForKey returns NO
    //By default if the key doesn't have anything yet.
    //NO - Play Music
    //YES - Don't Play Music
    stopMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"stopMusic"];
    muteSounds = [[NSUserDefaults standardUserDefaults] boolForKey:@"muteSounds"];
    
    //Updates the segmented controllers to reflect internal settings
    if(stopMusic){
        musicSegControl.selectedSegmentIndex = 1;
    }
    else{
        musicSegControl.selectedSegmentIndex = 0;
    }
    
    if(muteSounds){
        soundSegControl.selectedSegmentIndex = 1;
    }
    else{
        soundSegControl.selectedSegmentIndex = 0;
    }
    
    _optionLabel.font = FONT_JS_STD(35);
    _musicLabelText.font = FONT_PO_STD(18);
    _soundLabelText.font = FONT_PO_STD(18);
    _nameLabelText.font = FONT_PO_STD(20);
    
    _updateButton.titleLabel.font = FONT_PO_STD(16);
    _backButton.titleLabel.font = FONT_PO_STD(18);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [playerName resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [playerName resignFirstResponder];
    return YES;
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

- (IBAction)changeName:(id)sender
{
    name = playerName.text;
    NSLog(@"name: %@",name);
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
    
    
}

//Responds to a change in the Music segmented controller
-(IBAction)musicSwitched:(id)sender
{
    if(app.backgroundMusicPlayer.playing){
        [app.backgroundMusicPlayer pause];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"stopMusic"];
    }
    else{
        [app.backgroundMusicPlayer play];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"stopMusic"];
    }
}

//Responds to a change in the Sound segmented controller
-(IBAction)soundSwitched:(id)sender
{
    NSLog(@"SWITCH");
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"muteSounds"] == YES){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"muteSounds"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"muteSounds"];
    }
}

@end
