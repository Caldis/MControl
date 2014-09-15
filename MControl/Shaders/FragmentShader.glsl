///
//  Shader.fsh
//  OpenGLTest
//
//  Created by 陈标 on 14-5-5.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    //带光照
    gl_FragColor = colorVarying;
}
