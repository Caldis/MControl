//
//  Shader.fsh
//  OpenGLTest
//
//  Created by cb on 14-5-5.
//  Copyright (c) 2014 Cb. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
