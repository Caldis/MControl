///
//  colorVideoStreamViewController.m
//  kinectClient
//
//  Created by 陈标 on 14-4-20.
//  Copyright (c) 2014年 Cb. All rights reserved.
//
//1字节:uint8_t,2字节:uint16_t,4字节:uint32_t,8字节:uint64_t
//             2字节:int     ,4字节:char

#import "depthVideoStreamViewController.h"

@interface depthVideoStreamViewController ()

@end

@implementation depthVideoStreamViewController

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
    
    self.ipLabel.text   = self.ipGetText;
    self.portLabel.text = self.portGetText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)returnToFirstPage:(id)sender{
    [iStream close];
    [oStream close];
    [iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [iStream setDelegate:Nil];
    [oStream setDelegate:Nil];
    self.connectionLabel.text = @"Wait To Connect ...";
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)connectToServer:(id)sender {
    
    CFReadStreamRef  readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    NSString  *ip   =  self.ipGetText;
    NSInteger  port = [self.portGetText intValue];
    //Mode1=DepthVideoStream
    uint8_t mode = 1;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)ip, (UInt32)port, &readStream, &writeStream);
    
    if(readStream && writeStream){
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
         iStream = (__bridge NSInputStream*)readStream;
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [iStream open];
        
         oStream = (__bridge NSOutputStream*)writeStream;
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [oStream open];
        
        [oStream write:&mode maxLength:sizeof(mode)];
    }
}


#pragma mark - Delegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    if(eventCode == NSStreamEventHasBytesAvailable){
        
        self.connectionLabel.text = @"Succeed to connect";
        NSMutableData *imgdata = [[NSMutableData alloc]init];
        
        /*Stream*/
        uint8_t buff[4];
        [(NSInputStream *)aStream read:buff maxLength:4]; // Read Length
        uint32_t dataLength = (buff[0] << 8) |(buff[1] << 8) |(buff[2] << 8) | buff[3];
        uint8_t tcpbuff[dataLength];
        
        dataLength = (uint32_t)[(NSInputStream *)aStream read:tcpbuff maxLength:dataLength]; // Read Data
        [imgdata appendBytes:(const void *)tcpbuff length:dataLength];
        /*END*/
        
        if([self dataIsVaildJPEG:imgdata]){
            [self.colorImageView setImage:[UIImage imageWithData:imgdata]];
        }
    }
}

-(BOOL)dataIsVaildJPEG:(NSData *)data{
    
    if(!data || data.length < 2){
        return NO;
    }
    NSInteger totalBytes = data.length;
    const char *bytes = (const char*)[data bytes];
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8 &&
            bytes[totalBytes-2] == (char)0xff &&
            bytes[totalBytes-1] == (char)0xd9);
}


@end
