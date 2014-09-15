///
//  ViewController.m
//  kinectClient
//
//  Created by 陈标 on 14-4-19.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import "mainViewController.h"

@interface mainViewController ()

@end

@implementation mainViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self textFidleInit];
    
    //初始化并且添加openDrawerButton
    UIImage *hamburger = [UIImage imageNamed:@"menubuttom"];
    self.openDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openDrawerButton.frame = CGRectMake(10.0f, 18.0f, 44.0f, 44.0f);
    [self.openDrawerButton setImage:hamburger forState:UIControlStateNormal];
    [self.openDrawerButton addTarget:self action:@selector(openDrawer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openDrawerButton];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterColorVideoStream:(id)sender {
}

- (IBAction)enterDepthVideoStream:(id)sender {
}

- (IBAction)hideKeyBoard:(id)sender {
    [self.ipField.textField resignFirstResponder];
    [self.portField.textField resignFirstResponder];
}

//输入框初始化
-(void)textFidleInit{
    //ip输入框
    NSString *ipRegex = @"[0-9]{1,3}+\\.[0-9]{1,3}+\\.[0-9]{1,3}+\\.[0-9]{1,3}";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    self.ipField.textField.text = @"192.168.123.1";
    self.ipField.textField.placeholder = @" Sever IP Address";
    [self.ipField.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    __weak mainViewController *weakSelf = self;
    [self.ipField setTextValidationBlock:^BOOL(NSString *text) {
        if (![ipTest evaluateWithObject:text]) {
            weakSelf.ipField.alertView.title = @"Invalid IP Address";
            return NO;
        } else {
            return YES;
        }
    }];
    self.ipField.delegate = self;
    
    //端口输入框
    NSString *portRegex = @"[0-9]{1,5}";
    NSPredicate *portTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", portRegex];
    self.portField.textField.text = @"9899";
    self.portField.textField.placeholder = @" Sever Port";
    self.portField.textField.clearButtonMode = UITextFieldViewModeAlways;
    [self.portField.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [self.portField setTextValidationBlock:^BOOL(NSString *text) {
        if (![portTest evaluateWithObject:text]) {
            weakSelf.portField.alertView.title = @"Invalid IP Address";
            return NO;
        } else {
            return YES;
        }
    }];
    self.portField.delegate = self;
}


#pragma mark - Configuring the view’s layout behavior
//设置状态栏
- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [segue.destinationViewController respondsToSelector:@selector(setipGetText:)];
    [segue.destinationViewController setValue:self.ipField.textField.text forKey:@"ipGetText"];
    [segue.destinationViewController respondsToSelector:@selector(setportGetText:)];
    [segue.destinationViewController setValue:self.portField.textField.text forKey:@"portGetText"];
}

@end

