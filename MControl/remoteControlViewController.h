//
//  remoteControlViewController.h
//  kinectClient
//
//  Created by Cyrus on 14-9-13.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"

@interface remoteControlViewController : UIViewController <ICSDrawerControllerChild, ICSDrawerControllerPresenting>

//ICSD
@property(nonatomic, weak) ICSDrawerController *drawer;
@property(nonatomic, strong) UIButton *openDrawerButton;

//JoyStick
@property (strong, nonatomic) IBOutlet UIImageView *joyStickHandler;
@property (strong, nonatomic) IBOutlet UIImageView *joyStickBase;
@property (strong, nonatomic) IBOutlet UILabel *touchPointLabel;
@property (strong, nonatomic) IBOutlet UILabel *handlerPointLabel;

@end
