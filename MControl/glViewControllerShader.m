///
//  glViewController-Shader.m
//  kinectClient
//
//  Created by 陈标 on 14-5-18.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

#import "glViewControllerShader.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define BufferSize 1200

//Attribute变量名索引(没有用到)
enum{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};
//Uniform变量名索引
enum{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

GLfloat gPointCloudData[7372800] = {0.0f};
GLfloat gTempData[307200] = {0.0f};

@implementation glViewControllerShader

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.ipLabel.text   = self.ipGetText;
    self.portLabel.text = self.portGetText;
    self.dataRecvLabel.text = [NSString stringWithFormat:@" "];
    self.dataAllRecvLabel.text = [NSString stringWithFormat:@" "];
    
    //创建EAGLContext实例
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //将glView设置为EAGLContext实例的引用
    GLKView *glView = (GLKView *)self.view;
    glView.context = self.context;
    //self.preferredFramesPerSecond = 60;
    //设置深度精度为24
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self sliderInit];
    [self geneData];
    [self setupGL];
}

- (void)setupGL{
    //设置当前线程操作的context
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    //启用深度测试
    glEnable(GL_DEPTH_TEST);
    
    //glGenVertexArraysOES(1, &_vertexArray);
    //glBindVertexArrayOES(_vertexArray);
    
    //创建Buffer标示符
    glGenBuffers(1, &_vertexBuffer);
    //设定Buffer标示符类型,
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    //传入数据(数据类型,大小,数据名称,使用类别)
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPointCloudData), gPointCloudData, GL_STATIC_DRAW);
    
    //+启用顶点位置(坐标)数组,GLKVertexAttribPosition是顶点属性集中“位置Position”属性的索引。
    //GLKVertexAttrib顶点属性集中包含五种属性：位置、法线、颜色、纹理0，纹理1。
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //传递顶点位置数据
    //1:顶点位置数据GLKVertexAttribPosition
    //2:每个点的数据个数，位置(x,y)2个或(x,y,z)3个,,颜色(r,g,b,a)4个
    //3:顶点的数据类型
    //4:是否使用归一化处理
    //5:跨度值
    //6:数据的地址
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    
    //+启用法线位置数组
    //glEnableVertexAttribArray(GLKVertexAttribNormal);
    //传递法线数据
    //1:顶点位置数据GLKVertexAttribNormal
    //2:每个点的数据个数,(x,y,z)3个
    //3:顶点的数据类型
    //4:是否使用归一化处理
    //5:跨度值
    //6:数据的地址
    //glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    //+启用颜色数组
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    //glBindVertexArrayOES(0);
}

#pragma mark -  OpenGL ES 2 shader compilation
//Shader加载函数
- (BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    //1.创建程序
    _program = glCreateProgram();
    
    //2.a.创建和编译Vertex Shader(顶点着色器)
    //    将Vertex Shader绑定到Shaderves文件
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    //2.b.创建和编译Fragment Shader(片段着色器)
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"FragmentShader" ofType:@"glsl"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    //3.a.链接Shader.vsh文件与program
    glAttachShader(_program, vertShader);
    //3.b.链接Shader.fsh文件与program
    glAttachShader(_program, fragShader);
    
    //4.绑定program与顶点和法线(program名称,要绑定的数据类型,数据名称)
    //  数据名称必须与Shader.vsh中的attribute相同对应
    //  在链接程序之前必须执行这一步
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    //glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribColor, "color");
    
    //5.链接程序
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    //6.获取uniform的地址(指针)(可选,可直接用glGetUniformLocation用于传递地址)
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    //7.断开Vertex Shader和Fragment Shader与program的链接,并且释放他们
    //  注意,program本身并没有被释放
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
//公共函数,Shader编译
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
//公共函数,program链接
- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark - GLKView and GLKViewController delegate methods
static CGFloat rotx = 0;
static CGFloat roty = 0;
static CGFloat movx = 0;
static CGFloat movy = 0;
//这个方法每一帧执行一次,第一次循环时，先调用“glkView”再调用“update”
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //定义清除屏幕的颜色
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    //清除屏幕
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    //指定draw使用的顶点数组
    glBindVertexArrayOES(_vertexArray);
    //绑定着色器到当前context,相当于prepareToDraw
    glUseProgram(_program);
    
    //输入数据到VertexShader,数据地址来自loadShader中保存的枚举变量
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    
    //绘图函数
    //1:opengl的绘制方式,这里选GL_TRIANGLE_STRIP
    //2:起始点
    //3:绘制的点个数,640*480=307200
    glDrawArrays(GL_POINTS, 0, 307200);
}
//这个方法每一帧执行一次
- (void)update{
    //创建一个正交投影矩阵
    //1:左边坐标2:右边坐标
    //3:下面坐标4:上面坐标
    //5:近处坐标6:远处坐标
    //其实就是定义一个视野区域，就是确定镜头看到的东西(设置镜头的大小)
    //GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-2, 2, -3, 3, -1, 1);
    
    //创建一个透视投影矩阵
    //1.视角，要求输入幅度，GLKMathDegreesToRadians帮助我们把角度值转换为幅度
    //2.宽高比
    //3.近平面
    //4.远平面
    //near和far共同决定了可视深度，都必须为正值，near一般设为一个比较小的数，far必须大于near
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(100.0f), aspect, 0.1f, 5000.0f);
    
    //公转
    //物体随手指移动
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(movx, -movy, -self.zoomSlider.value*50);

    //GLKMatrix4Rotate做矩阵旋转
    //它有5个参数：
    //参数1：传入矩阵，被变化的矩阵
    //参数2：旋转的角度。正值逆时针旋转。
    //参数3～5：共同组成一个向量，围绕这个向量做旋转
    //baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, rotx*0.0176f, 0.0f, 1.0f, 0.0f);
    
    
    //自转
    //使用OpenGL ES2计算矩阵
    //将物体往XYZ方向移动
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    
    //GLKMatrix4Rotate做矩阵旋转,随手指转动
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotx*0.0176f, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, roty*0.0176f, 1.0f, 0.0f, 0.0f);
    
    //矩阵相乘,共同作用
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    //将矩阵变化保存在这两个参数中,glkView函数draw时作为参数传递给Shader.vsh
    //GLKMatrix4GetMatrix3从4X4矩阵中的左上角提取一个3X3矩阵
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

//触摸旋转,移动函数
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    NSUInteger numTouches = [touches count];
    
    //双指移动
    if(numTouches == 2) {
        CGFloat move_movx = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        movx = movx + move_movx;
        CGFloat move_movy = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        movy = movy + move_movy;

        
    }
    
    //单指旋转
    if(numTouches == 1){
        CGFloat move_rotx = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        rotx = rotx + move_rotx;
        CGFloat move_roty = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        if (roty <= 180) {
            roty = roty + move_roty;
        }
        else{
            roty = 180;
        }
        
        if (roty >= 0) {
            roty = roty + move_roty;
        }
        else
            roty = 0;
    }
}

uint8_t ref = 1;
int     networkState = 0;
- (IBAction)refreshData:(id)sender {
    switch (networkState) {
        case 0:{
            CFReadStreamRef  readStream  = NULL;
            CFWriteStreamRef writeStream = NULL;
            
            NSString  *ip   =  self.ipGetText;
            NSInteger  port = [self.portGetText intValue];
            //Mode2=PointCloudData
            uint8_t mode = 2;
            
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
                
                [oStream write:&mode maxLength:(mode)];
            }
            networkState = 1;
            break;
        }
        case 1:
            NSLog(@"refresh press");
            bytesNowRead = 0;
            [oStream write:&ref maxLength:(ref)];
            break;
        default:
            break;
    }
}
#pragma mark - Delegate
uint32_t bytesNowRead = 0;
int dataLength = 0;
int bytesAllRead = 0;
int len = 0;
-(void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{

	switch (eventCode) {
		case NSStreamEventHasBytesAvailable: {
            
			if (!receivedData) {
                receivedData = [[NSMutableData alloc] init];
            }
            
            //手动刷新
            if (1) {
                //包头,数据大小
                while (dataLength == 0) {
                    uint8_t buff[4];
                    [(NSInputStream *)stream read:buff maxLength:4]; // Read Length
                    [receivedData appendBytes:(const void *)buff length:4];
                    [receivedData getBytes:&dataLength length:4];
                    NSLog(@"Datalength is : %i",dataLength);
                    [receivedData resetBytesInRange:NSMakeRange(0, [receivedData length])];
                    [receivedData setLength:0];
                }
                
                 //数据内容
                 uint8_t buf[BufferSize];
                 len = (int)[(NSInputStream *)stream read:buf maxLength:BufferSize];
                 if (len) {
                 [receivedData appendBytes:(const void *)buf length:len];
                 bytesNowRead = bytesNowRead + len;
                 bytesAllRead = bytesAllRead + len;
                 self.dataRecvLabel.text = [NSString stringWithFormat:@"%i",bytesNowRead];
                 self.dataAllRecvLabel.text = [NSString stringWithFormat:@"%i",bytesAllRead];
                 }
                [self updateDataFrom:receivedData];
            }
            
            //自动刷新
            /*
            if (0) {
                uint32_t dataLength = 1228800; //sizeof(float)*640*480
                uint8_t buf[BufferSize];
                len = (int)[(NSInputStream *)stream read:buf maxLength:BufferSize];
                if (len) {
                    bytesNowRead = bytesNowRead + len;
                    bytesAllRead = bytesAllRead + len;
                    self.dataRecvLabel.text = [NSString stringWithFormat:@"%i",bytesNowRead];
                    self.dataAllRecvLabel.text = [NSString stringWithFormat:@"%i",bytesAllRead];
                    if ((dataLength - bytesNowRead) >= BufferSize) {
                        [receivedData appendBytes:(const void *)buf length:len];
                    }
                    else{
                        [receivedData appendBytes:(const void *)buf length:(dataLength - bytesNowRead)];
                        [self updateDataFrom:receivedData withLength:dataLength];
                        uint8_t *buffer = &buf[dataLength - bytesNowRead + 1];
                        [receivedData appendBytes:(const void *)buffer length:(BufferSize - (dataLength -  bytesNowRead))];
                        bytesNowRead = BufferSize - (dataLength - bytesNowRead);
                    }
                }
            }
            */
            break;
        }
		default: {
            break;
        }
	}
}

//滑动条
-(void)sliderInit{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [self.zoomSlider setNumberFormatter:formatter];
    self.zoomSlider.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:26];
    self.zoomSlider.popUpViewAnimatedColors = @[[UIColor purpleColor], [UIColor redColor], [UIColor orangeColor]];

}
//填充原始数据
-(void)geneData{
    int   pNum = 0;
    float rr = 0.0f;
    float gg = 0.0f;
    float bb = 0.0f;
    for (int i = 0; i < 640; ++i) {
        for (int j = 0; j < 480; ++j){
            gPointCloudData[pNum]   = (float)i-320;
            gPointCloudData[pNum+1] = (float)j-240;
            if (i == 0|j == 0|i == 639|j == 479) {
                gPointCloudData[pNum+3] = 0.0f;
                gPointCloudData[pNum+4] = 0.0f;
                gPointCloudData[pNum+5] = 1.0f;
            }
            else{
                gPointCloudData[pNum+3] = rr;
                gPointCloudData[pNum+4] = gg;
                gPointCloudData[pNum+5] = bb;
            }
            pNum = pNum + 6;
        }
    }
}
//填充深度数据(手动)
-(void)updateDataFrom:(NSMutableData*)recData{
    int gNum = 2;
    if (bytesNowRead == dataLength) {
        [recData getBytes:&gTempData length:dataLength];
        for (int i = 0; i < 307200; ++i) {
            gPointCloudData[gNum] = gTempData[i];
            gNum = gNum + 6;
        }
        glBufferData(GL_ARRAY_BUFFER, sizeof(gPointCloudData), gPointCloudData, GL_STATIC_DRAW);
        [recData resetBytesInRange:NSMakeRange(0, [recData length])];
        [recData setLength:0];
    }
}
//填充深度数据(自动)
-(void)updateDataFrom:(NSMutableData*)recData withLength:(uint32_t)dataLength{
    int res = 640*480*sizeof(float);
    int gNum = 2;
    [recData getBytes:&gTempData length:res];
    for (int i = 0; i < 307200; ++i) {
        gPointCloudData[gNum] = gTempData[i];
        gNum = gNum + 6;
    }
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPointCloudData), gPointCloudData, GL_STATIC_DRAW);
    [recData resetBytesInRange:NSMakeRange(0, [recData length])];
    [recData setLength:0];
}

//交换Data
-(void)exchangeMutableData:(NSMutableData*) receivedData1 to:(NSMutableData*) receivedData2{
    
}
//生成随机数据
-(void)geneRandamData{
    int pointNum = 1;
    int pointByte = 0;
    for (int x = 0; x < 640; x++) {
        for (int y = 0; y < 480; y++) {
            pointByte = (pointNum - 1) * 6;
            float z = 5*(rand() /(double)(RAND_MAX/100));
            float r = rand()/(double)(RAND_MAX);
            float g = rand()/(double)(RAND_MAX);
            float b = rand()/(double)(RAND_MAX);
            gPointCloudData[pointByte]   = (float)x-320;
            gPointCloudData[pointByte+1] = (float)y-240;
            gPointCloudData[pointByte+2] = -z;
            gPointCloudData[pointByte+3] = r;
            gPointCloudData[pointByte+4] = g;
            gPointCloudData[pointByte+5] = b;
            pointNum = pointNum + 1;
        }
    }
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPointCloudData), gPointCloudData, GL_STATIC_DRAW);

}
//返回
-(void)returnToFirstPage:(id)sender{
    [EAGLContext setCurrentContext:self.context];
    
    //glDeleteBuffers(1, &_vertexBuffer);
    //glDeleteVertexArraysOES(1, &_vertexArray);
    //[EAGLContext setCurrentContext:nil];
    
    [iStream close];
    [oStream close];
    [iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [iStream setDelegate:Nil];
    [oStream setDelegate:Nil];
    networkState = 0;
    
    [receivedData resetBytesInRange:NSMakeRange(0, [receivedData length])];
    [receivedData setLength:0];
    
    self.connectionLabel.text = @"Wait To Connect ...";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)show:(id)sender {
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPointCloudData), gPointCloudData, GL_STATIC_DRAW);
}

- (void)tearDownGL{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}
- (void)dealloc{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}


@end

