///
//  ViewController.h
//  kinectClient
//
//  Created by 陈标 on 14-4-19.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZGFormField.h"
#import "ASValueTrackingSlider.h"
#import "ICSDrawerController.h"

@protocol BZGFormFieldDelegate;

@interface mainViewController : UIViewController <BZGFormFieldDelegate,ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property (strong, nonatomic) IBOutlet BZGFormField *ipField;
@property (strong, nonatomic) IBOutlet BZGFormField *portField;

- (IBAction)enterColorVideoStream:(id)sender;
- (IBAction)enterDepthVideoStream:(id)sender;
- (IBAction)hideKeyBoard:(id)sender;

//ICSD
@property(nonatomic, weak) ICSDrawerController *drawer;
@property(nonatomic, strong) UIButton *openDrawerButton;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
