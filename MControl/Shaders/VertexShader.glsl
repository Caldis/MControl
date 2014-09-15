///
//  Shader.vsh
//  OpenGLTest
//
//  Created by 陈标 on 14-5-5.
//  Copyright (c) 2014年 Cb. All rights reserved.
//

//坐标数据,vec4表示4个浮点数组成的向量
attribute vec4 position;
//法线向量数据,vec3表示3个浮点数组成的向量
//attribute vec3 normal;
//颜色数据,必须是vec4
attribute vec4 color;

//varying表示易变变量,这类数据传递给FragmentShader,需要同时在两个Shader中定义
varying lowp vec4 colorVarying;

//uniform表示只读
//模型视图矩阵数据,mat4表示4x4矩阵
uniform mat4 modelViewProjectionMatrix;
//法线矩阵数据,mat3表示3x3矩阵
uniform mat3 normalMatrix;

void main()
{
    //************光照************
    //设定视点
    //vec3 eyeNormal = normalize(normalMatrix * normal);
    //光线位置
    //vec3 lightPosition = vec3(0.0, 1.0, 1.0);
    //光颜色
    //vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    //dot,点乘函数;max,返回两个值中大的一个
    //float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    //传递数据给FragmentShader,(带有光照)
    //colorVarying = diffuseColor * nDotVP;
    
    colorVarying = color;
    
    gl_Position = modelViewProjectionMatrix * position;
    
    gl_PointSize = 4.0;
}