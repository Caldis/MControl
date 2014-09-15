//
//  remoteControlViewController.m
//  kinectClient
//
//  Created by Cyrus on 14-9-13.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import "remoteControlViewController.h"

#define JOYHANDLER_CENTER_OFFSET 1.0f
#define JOYHANDLER_CENTER_BACK_DELAY 0.15f
#define JOYHANDLER_CENTER_FOLLOW_DELAY 0.08f

@interface remoteControlViewController ()
{
    UIImage *stickNormalImg;
    UIImage *stickPressImg;
}
@end

@implementation remoteControlViewController

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
    
    //初始化并且添加openDrawerButton
    UIImage *hamburger = [UIImage imageNamed:@"menubuttom"];
    self.openDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openDrawerButton.frame = CGRectMake(10.0f, 18.0f, 44.0f, 44.0f);
    [self.openDrawerButton setImage:hamburger forState:UIControlStateNormal];
    [self.openDrawerButton addTarget:self action:@selector(openDrawer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openDrawerButton];
    
    //Joystick
    stickNormalImg = [UIImage imageNamed:@"joyStickNormal.png"];
    stickPressImg  = [UIImage imageNamed:@"joyStickPress.png"];
    CGPoint pos = [self imgCenterPosition:self.joyStickHandler];
    self.handlerPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)pos.x, (int)pos.y];
    self.touchPointLabel.text = [NSString stringWithFormat:@"No touch"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - ICSDrawerControllerPresenting
//开/关侧边菜单的时候是否响应用户操作
- (void)drawerControllerWillOpen:(ICSDrawerController  *)drawerController{
    self.view.userInteractionEnabled = YES;
    self.openDrawerButton.userInteractionEnabled = YES;
}
- (void)drawerControllerDidOpen:(ICSDrawerController   *)drawerController{
    self.view.userInteractionEnabled = NO;
    self.openDrawerButton.userInteractionEnabled = NO;
}
- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = NO;
    self.openDrawerButton.userInteractionEnabled = NO;
}
- (void)drawerControllerDidClose:(ICSDrawerController  *)drawerController{
    self.view.userInteractionEnabled = YES;
    self.openDrawerButton.userInteractionEnabled = YES;
}

//点击菜单按钮的操作
- (void)openDrawer:(id)sender{
    [self.drawer open];
}

#pragma mark - JoyStick
//显示手指坐标
- (void)calculatePosition:(NSSet *)fingerPosition
{
    UITouch *touch = [fingerPosition anyObject];
    CGPoint  point = [touch locationInView:[touch view]];
    NSLog(@"point x is : %f, y is : %f", point.x, point.y);
}

//计算图片中心坐标
- (CGPoint)imgCenterPosition:(UIImageView *)img
{
    CGSize  size = img.frame.size;
    CGPoint posi = img.frame.origin;
    CGPoint center;
    center.x = posi.x + size.width  / 2;
    center.y = posi.y + size.height / 2;
    return center;
}

//判断点击位置是否落在摇杆底座内
- (BOOL)touchPositionInBase:(UITouch *)touch
{
    CGPoint  point = [touch locationInView:[touch view]];
    CGPoint  baseCenter = [self imgCenterPosition:self.joyStickBase];
    CGFloat  leng  = sqrt((point.x - baseCenter.x) * (point.x - baseCenter.x) + (point.y - baseCenter.y) * (point.y - baseCenter.y));
    CGFloat  radi  = self.joyStickBase.frame.size.height / 2;
    if (leng > radi) {
        return FALSE;
    }
    else{
        return TRUE;
    }
}

//点击开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.joyStickHandler.image = stickPressImg;
    UITouch *touch = [touches anyObject];
    if ([self touchPositionInBase:touch]) {
        [self moveJoyStickHandler:[touch locationInView:[touch view]]];
    }
    else{
        [self moveJoyStickHandlerOut:[touch locationInView:[touch view]]];
    }
    CGPoint pos = [self imgCenterPosition:self.joyStickHandler];
    self.handlerPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)pos.x, (int)pos.y];
    CGPoint tps = [touch locationInView:[touch view]];
    self.touchPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)tps.x, (int)tps.y];
}

//点击移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.joyStickHandler.image = stickPressImg;
    UITouch *touch = [touches anyObject];
    if ([self touchPositionInBase:touch]) {
        [self moveJoyStickHandler:[touch locationInView:[touch view]]];
    }
    else{
        [self moveJoyStickHandlerOut:[touch locationInView:[touch view]]];
    }
    CGPoint pos = [self imgCenterPosition:self.joyStickHandler];
    self.handlerPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)pos.x, (int)pos.y];
    CGPoint tps = [touch locationInView:[touch view]];
    self.touchPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)tps.x, (int)tps.y];
}

//点击结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.joyStickHandler.image = stickNormalImg;
    CGPoint base = [self imgCenterPosition:self.joyStickBase];
    //[self moveJoyStickHandler:base];
    [UIView animateWithDuration:(JOYHANDLER_CENTER_BACK_DELAY) animations:^{
        self.joyStickHandler.frame = CGRectMake(base.x - self.joyStickHandler.frame.size.width / 2, base.y - self.joyStickHandler.frame.size.height / 2, self.joyStickHandler.frame.size.width, self.joyStickHandler.frame.size.height);
    }];
    CGPoint pos = [self imgCenterPosition:self.joyStickHandler];
    self.handlerPointLabel.text = [NSString stringWithFormat:@"%d, %d", (int)pos.x, (int)pos.y];
    self.touchPointLabel.text = [NSString stringWithFormat:@"No touch"];
}

//触点在基座范围内,移动摇杆到指定坐标
- (void)moveJoyStickHandler:(CGPoint)position
{
    CGRect fr = self.joyStickHandler.frame;
    CGSize si = self.joyStickHandler.frame.size;
    fr.origin.x = position.x - si.width  / 2;
    fr.origin.y = position.y - si.height / 2;
    [UIView animateWithDuration:(JOYHANDLER_CENTER_FOLLOW_DELAY) animations:^{
        self.joyStickHandler.frame = CGRectMake(fr.origin.x, fr.origin.y, self.joyStickHandler.frame.size.width, self.joyStickHandler.frame.size.height);
    }];
}

//触点在基座范围外,移动摇杆到基座边框
-(void)moveJoyStickHandlerOut:(CGPoint)position
{
    CGPoint  baseCenter = [self imgCenterPosition:self.joyStickBase];
    CGFloat  baseRadi = self.joyStickBase.frame.size.height / 2;
    CGFloat  handlerRadi = self.joyStickHandler.frame.size.height / 2;
    CGRect   fr = self.joyStickHandler.frame;
    CGFloat  leng = sqrt((position.x - baseCenter.x) * (position.x - baseCenter.x) + (position.y - baseCenter.y) * (position.y - baseCenter.y));
    CGFloat  diff = baseRadi / leng;
    fr.origin.x = baseCenter.x - handlerRadi + (position.x - baseCenter.x) * diff * JOYHANDLER_CENTER_OFFSET;
    fr.origin.y = baseCenter.y - handlerRadi + (position.y - baseCenter.y) * diff * JOYHANDLER_CENTER_OFFSET;
    [UIView animateWithDuration:(JOYHANDLER_CENTER_FOLLOW_DELAY) animations:^{
        self.joyStickHandler.frame = CGRectMake(fr.origin.x, fr.origin.y, self.joyStickHandler.frame.size.width, self.joyStickHandler.frame.size.height);
    }];
}


@end
