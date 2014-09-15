//
//  menuViewControllerTableViewController.m
//  DailySF
//
//  Created by 陈标 on 6/22/14.
//  Copyright (c) 2014 Cb. All rights reserved.
//

#import "menuViewController.h"
#import "mainViewController.h"
#import "remoteControlViewController.h"

static NSString * const kICSColorsViewControllerCellReuseId = @"kICSColorsViewControllerCellReuseId";

@interface menuViewController ()

@property(nonatomic, strong) NSArray *colors;
@property(nonatomic, strong) NSArray *menuList;
@property(nonatomic, assign) NSInteger previousRow;
@property(nonatomic, strong) mainViewController *centerMain;
@property(nonatomic, strong) remoteControlViewController *centerRC;

@end

@implementation menuViewController

//初始化色彩
- (id)initWithColors:(NSArray *)colors{
    NSParameterAssert(colors);
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.colors = colors;
    }
    return self;
}
//初始化菜单
- (id)initWithMenus:(NSArray *)menuList andColors:(NSArray *)colors{
    NSParameterAssert(menuList);
    NSParameterAssert(colors);

    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.menuList = menuList;
        self.colors = colors;
    }
    return self;
}

#pragma mark - Managing the view
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kICSColorsViewControllerCellReuseId];
    //设置为无分割线
     self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Load the view
    UIStoryboard* storyboardMain = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.centerMain = (mainViewController *)[storyboardMain instantiateViewControllerWithIdentifier:@"mainCenterViewController"];
    UIStoryboard* storyboardRC = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.centerRC = (remoteControlViewController *)[storyboardRC instantiateViewControllerWithIdentifier:@"remoteControlViewController"];
}

//设定状态栏
#pragma mark - Configuring the view’s layout behavior
//设定状态栏风格
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
//状态栏是否隐藏
- (BOOL)prefersStatusBarHidden{
    return NO;
}

//设定TableView
#pragma mark - Table view data source
//多少个Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//每个Sections多少行（Cell）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(self.menuList);
    return self.menuList.count;
}
//设定每行（Cell）的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(self.menuList);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kICSColorsViewControllerCellReuseId forIndexPath:indexPath];
    cell.textLabel.text = [self.menuList objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundColor = self.colors[indexPath.row];
    
    return cell;
}

//设定点击相应的TableView后的动作
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.previousRow) {
        //关闭drawer
        [self.drawer close];
    }
    else {
        switch (indexPath.row) {
            case 0:{
                //替换当前的CenterViewController为Storybroad中的mainCenterViewController
                [self.drawer replaceCenterViewControllerWithViewController:self.centerMain];
                break;
            }
            case 1:{
                //替换当前的CenterViewController为Storybroad中的remoteControlViewController
                [self.drawer replaceCenterViewControllerWithViewController:self.centerRC];
                break;
            }
            default:
                break;
        }
    }
    self.previousRow = indexPath.row;
}

#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen: (ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = NO;
}
- (void)drawerControllerDidOpen:  (ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = YES;
}
- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = NO;
}
- (void)drawerControllerDidClose: (ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = YES;
}

@end
