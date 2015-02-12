//
//  OpeningViewController.m
//  Compliments
//
//  Created by Kevin Yao on 5/2/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import "OpeningViewController.h"
#define FONT_JS_STD(s) [UIFont fontWithName:@"JosefinSans" size:s]
#define FONT_PO_STD(s) [UIFont fontWithName:@"Poiret One" size:s]

@interface OpeningViewController ()

@end

@implementation OpeningViewController

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
    /*for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }*/
    
    _Logo.font = FONT_JS_STD(40.0f);
    _playButton.titleLabel.font = FONT_PO_STD(16.0f);
    _optionsButton.titleLabel.font = FONT_PO_STD(16.0f);
    _highScoreButton.titleLabel.font = FONT_PO_STD(16.0f);
    
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

@end
