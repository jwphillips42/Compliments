//
//  AppDelegate.h
//  Compliments
//
//  Created by James Phillips on 4/7/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AVAudioPlayer* backgroundMusicPlayer;

@end
