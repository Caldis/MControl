//
//  menuViewControllerTableViewController.h
//  DailySF
//
//  Created by 陈标 on 6/22/14.
//  Copyright (c) 2014 Cb. All rights reserved.
//

#import "ICSDrawerController.h"

@interface menuViewController : UITableViewController <ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak)   ICSDrawerController *drawer;

- (id)initWithColors:(NSArray *)colors;
- (id)initWithMenus:(NSArray *)menuList andColors:(NSArray *)colors;

@end
