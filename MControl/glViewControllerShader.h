///
//  glViewController-Shader.h
//  kinectClient
//
//  Created by 陈标 on 14-5-18.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "mainViewController.h"

@interface glViewControllerShader : GLKViewController <NSStreamDelegate>{
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    NSInputStream  *iStream;
    NSOutputStream *oStream;
    NSMutableData  *receivedData;
}

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;

- (IBAction)returnToFirstPage:(id)sender;
- (IBAction)refreshData:(id)sender;
- (IBAction)show:(id)sender;

@property (weak, nonatomic) IBOutlet ASValueTrackingSlider *zoomSlider;

@property (strong,nonatomic) NSString *ipGetText;
@property (strong,nonatomic) NSString *portGetText;

@property (strong, nonatomic) EAGLContext* context;
@property (strong, nonatomic) GLKBaseEffect* effect;

@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel *portLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataRecvLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataAllRecvLabel;

@end
