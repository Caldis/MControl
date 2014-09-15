///
//  colorVideoStreamViewController.h
//  kinectClient
//
//  Created by 陈标 on 14-4-20.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"


@interface colorVideoStreamViewController : UIViewController <NSStreamDelegate> {
    NSInputStream  *iStream;
    NSOutputStream *oStream;
    int jpegHead, jpegEnd;
}
@property (weak, nonatomic) IBOutlet UILabel     *connectionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UILabel     *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel     *portLabel;

@property (strong,nonatomic) NSString *ipGetText;
@property (strong,nonatomic) NSString *portGetText;

- (IBAction)connectToServer:(id)sender;
- (IBAction)returnToFirstPage:(id)sender;

@end
